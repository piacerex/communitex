defmodule BasicWeb.DistributorLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Distributors

  @impl true
  def update(%{distributor: distributor} = assigns, socket) do
    changeset = Distributors.change_distributor(distributor)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"distributor" => distributor_params}, socket) do
    changeset =
      socket.assigns.distributor
      |> Distributors.change_distributor(distributor_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"distributor" => distributor_params}, socket) do
    save_distributor(socket, socket.assigns.action, distributor_params)
  end

  defp save_distributor(socket, :edit, distributor_params) do
    case Distributors.update_distributor(socket.assigns.distributor, distributor_params) do
      {:ok, _distributor} ->
        {:noreply,
         socket
         |> put_flash(:info, "Distributor updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_distributor(socket, :new, distributor_params) do
    case Distributors.create_distributor(distributor_params) do
      {:ok, _distributor} ->
        {:noreply,
         socket
         |> put_flash(:info, "Distributor created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
