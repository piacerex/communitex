defmodule BasicWeb.ItemLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Items

  require ExImageInfo

  @impl true
  def update(%{item: item} = assigns, socket) do
    changeset = Items.change_item(item)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:uploaded_files, [])
     |> allow_upload(:avatar, accept: :any, max_entries: 1)}
  end

  @impl true
  def handle_event("validate", %{"item" => item_params}, socket) do
    changeset =
      socket.assigns.item
      |> Items.change_item(item_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"item" => item_params}, socket) do
    save_item(socket, socket.assigns.action, item_params)
  end

  defp save_item(socket, :edit, item_params) do
    image = binary_upload_file(socket)
    save_image = case image do
      nil -> socket.assigns.item.image
      _ -> image
    end

    case Items.update_item(socket.assigns.item, Map.put(item_params, "image", save_image)) do
      {:ok, _item} ->
        {:noreply,
        socket
        |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  defp save_item(socket, :new, item_params) do
    image = binary_upload_file(socket)
    case Items.create_item(Map.put(item_params, "image", image)) do
      {:ok, _item} ->
        {:noreply,
        socket
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
