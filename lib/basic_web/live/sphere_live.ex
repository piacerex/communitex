defmodule BasicWeb.SphereLive do
  use BasicWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    content = if params["content"] == nil || params["content"] == "", do: "communitex.org", else: params["content"]  #TODO: "communitex"のようなデフォルトをconfigで指定可能に
    content_folder = Path.join("content", content)
    css_pysical_folder = Path.join([Application.fetch_env!(:sphere, :local_root), content_folder, "css"])
    style = if params["style"] == nil || params["style"] == "" do
        ""
      else
        if File.exists?(Path.join(css_pysical_folder, params["style"])) do
          params["style"] <> "/"
        else
          ""
        end
      end
    cdns_file = Path.join([css_pysical_folder, style, "cdns.html"])
    cdns = if File.exists?(cdns_file), do: File.read!(cdns_file), else: ""
    {:ok, assign(socket, params: params, ui: %{"style" => style, "cdns" => cdns})}
  end

  @impl true
  def render(assigns) do
    params = assigns.params
    path_ = if params["path_"] != nil do
        params["path_"]
      else
        assigns.__changed__.params["path_"]
      end

    content_path = if path_ == [], do: "", else: Path.join(path_)
    folder = Application.fetch_env!( :sphere, :content_folder )

    try do
      content_path = PagePath.complement_pagename( content_path, folder )
      paths = build_paths( content_path, folder )
      fixed_path = PagePath.fix_at_path_end_to_slash( paths.relative_path, folder )
      if fixed_path != paths.relative_path, do: push_redirect( assigns.socket, to: fixed_path )

#      conn = SphereCustom.pre( conn, %{} )

      { template, new_params } = case File.read( paths.absolute_path ) do
        { :ok, body } -> 
#          parsed = Markdown.dispatch( paths.relative_path, body, params, conn, current_user( conn ) )
          parsed = Markdown.dispatch( paths.relative_path, body, params, nil )

          merge_params = Map.merge( params, parsed )
          { "index.html", merge_params }
        _   -> 
          #TODO: ココで障害Slack通知
          # { "[Sphere] Content Load error: #{ content_path }", params }

          error_paths = build_paths( "/error/404.html.eex", folder )
          error_params = case File.read( error_paths.absolute_path ) do
            { :ok, error_body } -> params |> Map.put( "path", "404.html" ) |> Map.put( "raw", "true" ) |> Map.put( "body", error_body )
            _                   -> params |> Map.put( "path", "404.html" ) |> Map.put( "raw", "true" ) |> Map.put( "body", "500 Internal Server Error" )
          end
          { "index.html", error_params }
      end

#      conn = SphereCustom.post( conn, %{ content_path: content_path } )

      Phoenix.View.render(BasicWeb.PageLiveView, template, params: new_params, ui: %{"css" => "communitex"}, error_message: nil)
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
        template = "index.html"
        Phoenix.View.render(BasicWeb.PageLiveView, template, params: error_params, error_message: nil)
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  @impl true
  def handle_event("update", params, socket) do
    {:noreply, assign(socket, params: params)}
  end

  defp apply_action(socket, :index, params) do
    socket
  end

  def current_user( conn ) do
    if Map.has_key?(conn.assigns, :current_user) && conn.assigns.current_user != nil do
      conn.assigns.current_user.email
    else
      "nobody"
    end
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
