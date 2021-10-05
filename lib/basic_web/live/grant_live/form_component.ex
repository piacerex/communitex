defmodule BasicWeb.GrantLive.FormComponent do
  use BasicWeb, :live_component

  import Ecto.Changeset

  alias Basic.Grants

  @impl true
  def update(%{grant: grant} = assigns, socket) do
    changeset = Grants.change_grant(List.first(grant))

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"grant" => grant_params}, socket) do
    changeset =
      List.first(socket.assigns.grant)
      |> Grants.change_grant(grant_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"grant" => grant_params}, socket) do
    if Grants.check_grant(grant_params) == [] do
      save_grant(socket, socket.assigns.action, grant_params)
    else
      changeset = 
        List.first(socket.assigns.grant)
        |> Grants.change_grant(grant_params)
        |> Map.put(:action, :validate)
        |> add_error(:user_id, "同一データは登録できません")
  
      {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_grant(socket, :edit, grant_params) do
    case Grants.update_grant(List.first(socket.assigns.grant), grant_params) do
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
