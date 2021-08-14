defmodule BasicWeb.GrantLive.Show do
  use BasicWeb, :live_view

  alias Basic.Grants

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:grant, Grants.get_grant!(id))}
  end

  defp page_title(:show), do: "Show Grant"
  defp page_title(:edit), do: "Edit Grant"
end
