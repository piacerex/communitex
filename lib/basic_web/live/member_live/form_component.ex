defmodule BasicWeb.MemberLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Members

  require ExImageInfo

  @impl true
  def update(%{member: member} = assigns, socket) do
    changeset = Members.change_member(member)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: :any, max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"member" => member_params}, socket) do
    changeset =
      socket.assigns.member
      |> Members.change_member(member_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"member" => member_params}, socket) do
    save_member(socket, socket.assigns.action, member_params)
  end

  defp save_member(socket, :edit, member_params) do
    image = binary_upload_file(socket)
    case Members.update_member(socket.assigns.member, Map.put(member_params, "image", image)) do
      {:ok, _member} ->
        {:noreply,
         socket
#         |> put_flash(:info, "Member updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_member(socket, :new, member_params) do
    image = binary_upload_file(socket)
    case Members.create_member(Map.put(member_params, "image", image)) do
      {:ok, _member} ->
        {:noreply,
         socket
#         |> put_flash(:info, "Member created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def binary_upload_file(socket) do
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry -> File.read!(path) end)
    |> List.last  # "Last" here means the first choised file
    |> case do
         nil    -> nil
         binary -> Base.encode64(binary)
       end
  end
end
