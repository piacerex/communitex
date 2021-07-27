defmodule PagePath do
  use BasicWeb, :controller

  @doc """
  Concat index.md if index.html.eex/index.html/index.json.eex does not exist

  ## Examples
    iex> PagePath.complement_pagename( "ntm/b03/v01d/index.html", "content/ddacademy.tech" )
    "ntm/b03/v01d/index.html"
    iex> PagePath.complement_pagename( "ntm/b03/v01d/", "content/ddacademy.tech" )
    "ntm/b03/v01d/index.html"
    iex> PagePath.complement_pagename( "ntm/no_exist_folder", "content/ddacademy.tech" )
    "ntm/no_exist_folder"
    iex> PagePath.complement_pagename( "mypage", "content/ddacademy.tech" )
    "mypage/index.html.eex"
    iex> PagePath.complement_pagename( "ntm", "content/ddacademy.tech" )
    "ntm/index.html"
    iex> PagePath.complement_pagename( "images", "content/ddacademy.tech" )
    "images/index.md"
  """
  def complement_pagename( content_path, folder ) do
    full_path = Path.join( [ folder, content_path ] )
    filename = cond do
      !File.dir?( full_path )                                       -> ""
      File.exists?( Path.join( [ full_path, "index.html.leex" ] ) ) -> "index.html.leex"
      File.exists?( Path.join( [ full_path, "index.json.leex" ] ) ) -> "index.json.leex"
      File.exists?( Path.join( [ full_path, "index.html.eex"  ] ) ) -> "index.html.eex"
      File.exists?( Path.join( [ full_path, "index.json.eex"  ] ) ) -> "index.json.eex"
      File.exists?( Path.join( [ full_path, "index.html"      ] ) ) -> "index.html"
      true                                                          -> "index.md"
    end
    Path.join( [ content_path, filename ] )
  end

  def default_filenames() do
    [ 
      "index.html.leex", 
      "index.json.leex", 
      "index.html.eex", 
      "index.json.eex", 
      "index.html", 
      "index.md", 
    ]
  end

  @doc """
  Fix at path end to slash

  ## Examples
    iex> PagePath.fix_at_path_end_to_slash( "/ntm/b03/v01d/", "content/ddacademy.tech" )
    "/ntm/b03/v01d/"
    iex> PagePath.fix_at_path_end_to_slash( "/ntm/b03/v01d", "content/ddacademy.tech" )
    "/ntm/b03/v01d/"
    iex> PagePath.fix_at_path_end_to_slash( "/ntm/b03/v01d/index.html", "content/ddacademy.tech" )
    "/ntm/b03/v01d/"
    iex> PagePath.fix_at_path_end_to_slash( "/", "content/ddacademy.tech" )
    "/"
    iex> PagePath.fix_at_path_end_to_slash( "", "content/ddacademy.tech" )
    "/"
  """
  def fix_at_path_end_to_slash( "",  _folder ), do: "/"
  def fix_at_path_end_to_slash( "/", _folder ), do: "/"
  def fix_at_path_end_to_slash( "/index.html.leex", _folder ), do: "/"
  def fix_at_path_end_to_slash( "/index.json.leex", _folder ), do: "/"
  def fix_at_path_end_to_slash( "/index.html.eex", _folder ), do: "/"
  def fix_at_path_end_to_slash( "/index.json.eex", _folder ), do: "/"
  def fix_at_path_end_to_slash( "/index.html", _folder ), do: "/"
  def fix_at_path_end_to_slash( "/index.md", _folder ), do: "/"
  def fix_at_path_end_to_slash( request_path, folder ) do
    full_path = Path.join( folder, request_path )
    case File.dir?( full_path ) && String.slice( request_path, -1, 1 ) != "/" do
      true -> request_path <> "/"
      _    -> 
        split_path = String.split( request_path, "/" ) |> Enum.filter( & &1 != "" )
        case split_path |> List.last |> String.contains?( default_filenames ) do
          true -> "/" <> ( Enum.drop( split_path, -1 ) |> Path.join ) <> "/"
          _    -> request_path
        end
    end
  end

end
