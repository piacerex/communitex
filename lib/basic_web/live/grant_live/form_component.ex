defmodule BasicWeb.GrantLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Grants

  @impl true
  def update(%{grant: grant} = assigns, socket) do
    changeset = Grants.change_grant(grant)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"grant" => grant_params}, socket) do
    changeset =
      socket.assigns.grant
      |> Grants.change_grant(grant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"grant" => grant_params}, socket) do
    save_grant(socket, socket.assigns.action, grant_params)
  end

  defp save_grant(socket, :edit, grant_params) do
    case Grants.update_grant(socket.assigns.grant, grant_params) do
      {:ok, _grant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Grant updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_grant(socket, :new, grant_params) do
    case Grants.create_grant(grant_params) do
      {:ok, _grant} ->
        {:noreply,
         socket
         |> put_flash(:info, "Grant created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
