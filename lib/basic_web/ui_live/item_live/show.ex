defmodule BasicWeb.ItemUiLive.Show do
  use BasicWeb, :live_view

  alias Basic.Items
  alias Basic.Accounts
  alias Basic.Orders.Order
  alias Basic.Orders

  @impl true
  def mount(_params, session, socket) do
    current_user_id = case session["user_token"] do
      nil -> ""
      token -> Accounts.get_user_by_session_token(token).id
    end
    {:ok,
      socket
      |> assign(:current_user_id, current_user_id)
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:item, Items.get_item!(id))}
  end

  def handle_event("buy", value, socket) do
    case socket.assigns.current_user_id do
      "" ->
        {:noreply, put_flash(socket, :error, "ログインしてから注文してください")}
      _ ->
        order_params = %{}
        case Orders.create_order(order_params
                                  |> Map.put_new(:user_id, socket.assigns.current_user_id)
                                  |> Map.put_new(:item_id, socket.assigns.item.id)
                                  |> Map.put_new(:price, socket.assigns.item.price)
                                  |> Map.put_new(:order_date, NaiveDateTime.utc_now)
                                  |> Map.put_new(:discount, 0)
                                  |> Map.put_new(:is_cancel, false)
                                  |> Map.put_new(:deleted_at, ~N[2016-01-01 00:00:00.000000])) do
          {:ok, _order} ->
            stocks = case socket.assigns.item.stocks do
              nil -> nil
              _   -> socket.assigns.item.stocks - 1
            end
            case Items.update_item(socket.assigns.item, Map.from_struct(Map.put(socket.assigns.item, :stocks, stocks))) do
              {:ok, _item} ->
                {:noreply, put_flash(socket, :info, "注文を受け付けました")}

                {:error, %Ecto.Changeset{} = changeset} ->
                  {:noreply, assign(socket, changeset: changeset)}
            end

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, changeset: changeset)}
        end
      end
  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
