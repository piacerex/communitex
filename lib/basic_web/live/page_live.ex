defmodule BasicWeb.PageLive do
  use BasicWeb, :live_view

  @impl true
  def mount(params, _session, socket) do
    {:ok, assign(socket, params: params)}
  end

  @impl true
  def render(assigns) do
    params = assigns.params
    path_ = params["path_"]
    content_path = if path_ == [], do: "index.html", else: Path.join(path_)
    Phoenix.View.render(BasicWeb.PageLiveView, content_path, assigns)
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, params) do
    socket
  end
end
