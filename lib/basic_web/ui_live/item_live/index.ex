defmodule BasicWeb.ItemUiLive.Index do
  use BasicWeb, :live_view

  alias Basic.Items
  alias Basic.Items.Item
  alias Basic.Accounts

  @impl true
  def mount(_params, session, socket) do
    current_user_id = case session["user_token"] do
      nil -> ""
      token -> Accounts.get_user_by_session_token(token).id
    end
    {:ok,
      socket
      |> assign(:items, Items.list_items_for_users())
      |> assign(:current_user_id, current_user_id)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Item")
    |> assign(:item, Items.get_item!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Item")
    |> assign(:item, %Item{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Items")
    |> assign(:item, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    item = Items.get_item!(id)
    {:ok, _} = Items.delete_item(item)

    {:noreply, assign(socket, :items, list_items())}
  end

  defp list_items do
    Items.list_items()
  end
end
