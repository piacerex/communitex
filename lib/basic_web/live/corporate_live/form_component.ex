defmodule BasicWeb.CorporateLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Corporates

  @impl true
  def update(%{corporate: corporate} = assigns, socket) do
    changeset = Corporates.change_corporate(corporate)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"corporate" => corporate_params}, socket) do
    changeset =
      socket.assigns.corporate
      |> Corporates.change_corporate(corporate_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"corporate" => corporate_params}, socket) do
    save_corporate(socket, socket.assigns.action, corporate_params)
  end

  defp save_corporate(socket, :edit, corporate_params) do
    case Corporates.update_corporate(socket.assigns.corporate, corporate_params) do
      {:ok, _corporate} ->
        {:noreply,
         socket
         |> put_flash(:info, "Corporate updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_corporate(socket, :new, corporate_params) do
    case Corporates.create_corporate(corporate_params) do
      {:ok, _corporate} ->
        {:noreply,
         socket
         |> put_flash(:info, "Corporate created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
