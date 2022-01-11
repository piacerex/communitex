defmodule BasicWeb.DeliveryUiLive.Show do
  use BasicWeb, :live_view

  alias BasicWeb.Address

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:delivery, Addresses.get_address!(id))}
  end

  defp page_title(:show), do: "Show Address"
  defp page_title(:edit), do: "Edit Address"
end
