defmodule BasicWeb.FileController do
  use BasicWeb, :controller

  def path_on_app( path ), do: "./" <> Application.fetch_env!( :sphere, :content_folder ) <> path

  def list( conn, params ) do
    param_path = if params == nil || params[ "path" ] == nil, do: "/", else: params[ "path" ] <> "/"
    path = path_on_app( param_path )
    result = File.ls( path ) |> Fl.handling
    json( conn, if is_list( result ) do
        result |> Enum.map( & 
          %{ 
            "is_folder"    => File.dir?( "#{ path }/#{ &1 }" ), 
            "is_open"    => false, "name" => &1, 
            "parent_folder"  => param_path, 
            "subordinate"  => [], 
            "is_add_file"  => false, 
            "is_add_folder"  => false, 
            "new_file"    => "", 
            "new_folder"  => "" 
          } 
        ) 
      else
        result
      end
    )
  end

  def upload( conn, params ) do
    path = path_on_app( params[ "path" ] )
    upload = params[ "file" ]
    result = File.cp( upload.path, "#{ path }/#{ upload.filename }", fn _, _ -> false end ) |> Fl.handling
    if String.starts_with?( params[ "path" ], "/api/" ) do
      File.cp( upload.path, Path.join( [ "./lib/basic_web/templates", params[ "path" ], upload.filename ] ), fn _, _ -> false end ) |> Fl.handling  #TODO: basic_webを直接指定しないように
    end

    GitOperator.push( Path.join( File.cwd!(), Application.fetch_env!( :sphere, :content_folder ) ), "add" )

    json( conn, result )
  end

  def new_file( conn, params ) do
    path = path_on_app( params[ "path" ] )
    result = File.touch( path ) |> Fl.handling
    if String.starts_with?( params[ "path" ], "/api/" ) do
      File.touch( Path.join( [ "./lib/basic_web/templates", params[ "path" ] ] ) ) |> Fl.handling  #TODO: basic_webを直接指定しないように
    end

    GitOperator.push( Path.join( File.cwd!(), Application.fetch_env!( :sphere, :content_folder ) ), "add" )

    json( conn, result )
  end

  def new_folder( conn, params ) do
    path = path_on_app( params[ "path" ] )
    result = File.mkdir( path ) |> Fl.handling
    if String.starts_with?( params[ "path" ], "/api/" ) do
      File.mkdir( Path.join( [ "./lib/basic_web/templates", params[ "path" ] ] ) ) |> Fl.handling  #TODO: basic_webを直接指定しないように
    end
    json( conn, result )
  end

  def remove( conn, params ) do
    path = path_on_app( params[ "path" ] )
    result = File.rm_rf( path ) |> Fl.handling
    if String.starts_with?( params[ "path" ], "/api/" ) do
      File.rm_rf( Path.join( [ "./lib/basic_web/templates", params[ "path" ] ] ) ) |> Fl.handling  #TODO: basic_webを直接指定しないように
    end

    GitOperator.push( Path.join( File.cwd!(), Application.fetch_env!( :sphere, :content_folder ) ), "remove" )

    json( conn, ( if is_list( result ), do: ( if result == [], do: "invalid path", else: "" ), else: result ) )
  end
end
