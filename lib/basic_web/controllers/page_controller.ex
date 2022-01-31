defmodule BasicWeb.PageController do
  use BasicWeb, :controller

  def index(conn, params) do
    path_ = params["path_"]
    content_path = if path_ == [], do: "index.html", else: Path.join(path_)
    render(conn, content_path, params: params)
  end
end
