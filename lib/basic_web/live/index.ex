defmodule BasicWeb.AdminLive.Index do
  use BasicWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, [])}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Admin")
  end

end
