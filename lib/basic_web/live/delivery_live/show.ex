defmodule BasicWeb.DeliveryLive.Show do
  use BasicWeb, :live_view

  alias Basic.Deliveries

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:delivery, Deliveries.get_delivery!(id))}
  end

  defp page_title(:show), do: "Show Delivery"
  defp page_title(:edit), do: "Edit Delivery"
end
