defmodule BasicWeb.DeliveryLive.Index do
  use BasicWeb, :live_view

  alias Basic.Deliveries
  alias Basic.Deliveries.Delivery

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :deliveries, list_deliveries())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Delivery")
    |> assign(:delivery, Deliveries.get_delivery!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Delivery")
    |> assign(:delivery, %Delivery{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Deliveries")
    |> assign(:delivery, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    delivery = Deliveries.get_delivery!(id)
    {:ok, _} = Deliveries.delete_delivery(delivery)

    {:noreply, assign(socket, :deliveries, list_deliveries())}
  end

  defp list_deliveries do
    Deliveries.list_deliveries()
  end
end
