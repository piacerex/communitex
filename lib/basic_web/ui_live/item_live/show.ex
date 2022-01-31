defmodule BasicWeb.ItemUiLive.Show do
  use BasicWeb, :live_view

  alias Basic.Items
  alias Basic.Accounts
  alias Basic.Orders.Order
  alias Basic.Orders
  alias Basic.Carts.Cart
  alias Basic.Carts

  @impl true
  def mount(_params, session, socket) do
    current_user_id = case session["account_token"] do
      nil -> ""
      token -> Accounts.get_account_by_session_token(token).id
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

  def handle_event( "submit", params, socket ) do
    item_stocks = Items.get_item!(socket.assigns.item.id).stocks

    cart = Carts.get_cart_by_user_and_item(socket.assigns.current_user_id, socket.assigns.item.id)
    quantity = case cart do
      nil  -> String.to_integer(params["quantity"])
      cart -> String.to_integer(params["quantity"]) + cart.quantity
    end

    cart_params = %{}

    case cart do
      nil ->
        case quantity > item_stocks do
          false ->
            case Carts.create_cart(cart_params
                                    |> Map.put_new(:user_id, socket.assigns.current_user_id)
                                    |> Map.put_new(:item_id, socket.assigns.item.id)
                                    |> Map.put_new(:quantity, quantity)
                                    |> Map.put_new(:is_order, false)) do
              {:ok, _cart} ->
                {:noreply,
                  socket
                  |> put_flash(:info, "カートに追加しました")
                  |> push_redirect(to: Routes.item_ui_index_path(socket, :index))
                }

              {:error, %Ecto.Changeset{} = changeset} ->
                {:noreply, assign(socket, changeset: changeset)}
            end
          true ->
            {:noreply,
              socket
              |> put_flash(:error, "注文数が在庫数を超えています")
            }
        end

      cart ->
        case quantity > item_stocks do
          false ->
            case Carts.update_cart(cart, cart_params
                                          |> Map.put_new(:user_id, socket.assigns.current_user_id)
                                          |> Map.put_new(:item_id, socket.assigns.item.id)
                                          |> Map.put_new(:quantity, quantity)
                                          |> Map.put_new(:is_order, false)) do
              {:ok, _cart} ->
                {:noreply,
                  socket
                  |> put_flash(:info, "カートを更新しました")
                  |> push_redirect(to: Routes.item_ui_index_path(socket, :index))
                }

              {:error, %Ecto.Changeset{} = changeset} ->
                {:noreply, assign(socket, :changeset, changeset)}
            end
          true ->
            {:noreply,
              socket
              |> put_flash(:error, "注文数が在庫数を超えています")
            }
        end
      end

  end

  defp page_title(:show), do: "Show Item"
  defp page_title(:edit), do: "Edit Item"
end
