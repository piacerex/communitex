defmodule BasicWeb.SphereController do  #TODO: 本来のコントローラ副作用部分と分離
  use BasicWeb, :controller
  require IEx

#TODO: cwdを使っている場所を:local_rootに変更

  def index( conn, %{ "path_" => path_ } = params ) do
#IEx.pry
    content_path = if path_ == [], do: "index.html", else: Path.join( path_ )
    folder = Application.fetch_env!( :sphere, :content_folder )

    try do
      fixed_path = PagePath.fix_at_path_end_to_slash( conn.request_path, folder )
      if fixed_path != conn.request_path, do: redirect( conn, to: fixed_path )
      content_path = PagePath.complement_pagename( content_path, folder )
      paths = build_paths( content_path, folder )

      conn = SphereCustom.pre( conn, %{} )

      { template, new_params } = case File.read( paths.absolute_path ) do
        { :ok, body } -> 
#          parsed = Markdown.dispatch( paths.relative_path, body, params, conn, current_user( conn ) )
          parsed = Markdown.dispatch( paths.relative_path, body, params, nil )
          merge_params = Map.merge( params, parsed )
          case merge_params[ "naked" ] do
            true -> { "naked.html",             merge_params }
            _    -> { "markdown_template.html", merge_params }
          end
        _   -> 
          #TODO: ココで障害Slack通知
          # { "[Sphere] Content Load error: #{ content_path }", params }

          error_paths = build_paths( "/error/404.html.eex", folder )
          error_params = case File.read( error_paths.absolute_path ) do
            { :ok, error_body } -> params |> Map.put( "path", "404.html" ) |> Map.put( "raw", "true" ) |> Map.put( "body", error_body )
            _                   -> params |> Map.put( "path", "404.html" ) |> Map.put( "raw", "true" ) |> Map.put( "body", "500 Internal Server Error" )
          end
          { "markdown_template.html", error_params }
      end

      conn = SphereCustom.post( conn, %{ content_path: content_path } )

      render( conn, template, params: new_params, error_message: nil )
    rescue
      error -> 
        #TODO: ココで障害Slack通知
        IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
        IO.inspect error
        IO.puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

        error_paths = build_paths( "/error/503.html.eex", folder )
        error_params = case File.read( error_paths.absolute_path ) do
          { :ok, error_body } -> params |> Map.put( "path", "503.html" ) |> Map.put( "raw", "true" ) |> Map.put( "body", error_body )
          _                   -> params |> Map.put( "path", "503.html" ) |> Map.put( "raw", "true" ) |> Map.put( "body", "500 Internal Server Error" )
        end
        template = "naked.html"
        render( conn, template, params: error_params, error_message: nil )
    end
  end

  def current_user( conn ) do
    if Map.has_key?(conn.assigns, :current_user) && conn.assigns.current_user != nil do
      conn.assigns.current_user.email
    else
      "nobody"
    end
  end

  def edit( conn, %{ "path_" => path_ } ), do: render( conn, "edit.html", params: 
  dispatch( conn, path_ ) )

  def show( conn, %{ "path_" => path_ } ), do: render( conn |> put_layout( "plane.html" ), "show.html", params: dispatch( conn, path_ ) )

  def dispatch(_conn, path_) do
    content_path = if path_ == [], do: "blank.html", else: Path.join( path_ )
    paths = build_paths( content_path, Application.fetch_env!( :sphere, :content_folder ) )
    body = Fl.read_if_exist( paths.absolute_path )

#    Markdown.dispatch( paths.relative_path, body, :no_eval, conn, current_user( conn ) )
    Markdown.dispatch( paths.relative_path, body, :no_eval, nil )
  end

  def build_paths( content_path, folder ) do
    pwd = File.cwd!()
    relative_path = [ Application.fetch_env!( :sphere, :content_root ), content_path ] |> Path.join()
    result = %{
      pwd:           File.cwd!(), 
      relative_path: relative_path, 
      absolute_path: [ pwd, folder, relative_path ] |> Path.join, 
    }
    result
  end
end
