defmodule BasicWeb.DeliveryLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Deliveries

  @impl true
  def update(%{delivery: delivery} = assigns, socket) do
    changeset = Deliveries.change_delivery(delivery)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"delivery" => delivery_params}, socket) do
    changeset =
      socket.assigns.delivery
      |> Deliveries.change_delivery(delivery_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"delivery" => delivery_params}, socket) do
    save_delivery(socket, socket.assigns.action, delivery_params)
  end

  defp save_delivery(socket, :edit, delivery_params) do
    case Deliveries.update_delivery(socket.assigns.delivery, delivery_params) do
      {:ok, _delivery} ->
        {:noreply,
         socket
         |> put_flash(:info, "Delivery updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_delivery(socket, :new, delivery_params) do
    case Deliveries.create_delivery(delivery_params) do
      {:ok, _delivery} ->
        {:noreply,
         socket
         |> put_flash(:info, "Delivery created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
