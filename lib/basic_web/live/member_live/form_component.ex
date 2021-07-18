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
    uploaded_files = 
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        type = ExImageInfo.seems? File.read!(path)
        dest = Path.join("content/communitex.org/images", 
                member_params["user_id"] <> "-" <> Date.to_string(NaiveDateTime.utc_now) <> "-" <> String.replace(Time.to_string(NaiveDateTime.utc_now), [":", "."], "") <> "." <> Atom.to_string(type))
        File.cp!(path, dest)
        Routes.static_path(socket, "/images/#{Path.basename(dest)}")
      end)

    do_edit_member(socket, member_params, uploaded_files)
  end

  defp do_edit_member(socket, member_params, uploaded_files) do
    if uploaded_files == [] do
      case Members.update_member(socket.assigns.member, Map.put(member_params, "image", socket.assigns.member.image)) do
        {:ok, _member} ->
          {:noreply,
          socket
          |> put_flash(:info, "Member updated successfully")
          |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    else
      case Members.update_member(socket.assigns.member, Map.put(member_params, "image", List.first(uploaded_files))) do
        {:ok, _member} ->
          {:noreply,
          socket
          |> put_flash(:info, "Member updated successfully")
          |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, :changeset, changeset)}
      end
    end
  end

  defp save_member(socket, :new, member_params) do
    uploaded_files = 
      consume_uploaded_entries(socket, :avatar, fn %{path: path}, _entry ->
        type = ExImageInfo.seems? File.read!(path)
        dest = Path.join("priv/static/images", 
                member_params["user_id"] <> "-" <> Date.to_string(NaiveDateTime.utc_now) <> "-" <> String.replace(Time.to_string(NaiveDateTime.utc_now), [":", "."], "") <> "." <> Atom.to_string(type))
        File.cp!(path, dest)
        Routes.static_path(socket, "/images/#{Path.basename(dest)}")
      end)

    do_save_member(socket, member_params, uploaded_files)
  end

# add
  defp do_save_member(socket, member_params, uploaded_files) do
    if uploaded_files == [] do
      case Members.create_member(Map.put(member_params, "image", "")) do
        {:ok, _member} ->
          {:noreply,
          socket
          |> put_flash(:info, "Member created successfully")
          |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    else
      case Members.create_member(Map.put(member_params, "image", List.first(uploaded_files))) do
        {:ok, _member} ->
          {:noreply,
          socket
          |> put_flash(:info, "Member created successfully")
          |> push_redirect(to: socket.assigns.return_to)}

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    end
  end
end
