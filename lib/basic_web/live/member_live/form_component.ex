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
     |> allow_upload(:avatar, accept: :any, max_entries: 3)}
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
    uploaded_files = save_upload_file(socket, member_params)
    image = if uploaded_files == [] do  # In the case of [], the file is not specified
      socket.assigns.member.image
    else
      if socket.assigns.member.image != nil do
        path = Path.join(Application.fetch_env!(:sphere, :content_folder), socket.assigns.member.image)
        File.rm(path)
      end
      List.last(uploaded_files)
    end
    case Members.update_member(socket.assigns.member, Map.put(member_params, "image", image)) do
      {:ok, _member} ->
        {:noreply,
        socket
        |> put_flash(:info, "Member updated successfully")
        |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_member(socket, :new, member_params) do
    uploaded_files = save_upload_file(socket, member_params)
    image = if uploaded_files == [] do  # In the case of [], the file is not specified
      ""
    else
      List.last(uploaded_files)
    end
    case Members.create_member(Map.put(member_params, "image", image)) do
      {:ok, _member} ->
        {:noreply,
        socket
        |> put_flash(:info, "Member created successfully")
        |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def save_upload_file(socket, member_params) do
    consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
      type = ExImageInfo.seems?(File.read!(path)) |> Atom.to_string |> String.replace("jpeg", "jpg")
      now = NaiveDateTime.utc_now
      dest = Path.join(
        [
          Application.fetch_env!(:sphere, :content_folder), 
          "/images/data/", 
          member_params["user_id"] <> "-" <> Date.to_string(now) <> "-" <> String.replace(Time.to_string(now), [":", "."], "") <> "." <> type
        ])
      File.cp!(path, dest)
      Routes.static_path(socket, "/images/data/#{Path.basename(dest)}")
    end)
  end
end
