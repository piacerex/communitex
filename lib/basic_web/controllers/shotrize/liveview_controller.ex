defmodule BasicWeb.LiveViewController do
  use Phoenix.LiveView

  def render(assigns) do
    params = assigns.params
    template = if params["path_"] == nil, do: "index.html", else: Path.join(params["path_"]) <> ".html"
    BasicWeb.PageLiveView.render(template, assigns)
  end

  def mount(params, _session, socket) do
    {:ok, assign(socket, params: params)}
  end
end
