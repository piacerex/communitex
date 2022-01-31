defmodule BasicWeb.CartUiLive.Register do
  use BasicWeb, :live_view

  alias Basic.Carts
  alias Basic.Accounts
  alias Basic.Members
  alias Basic.Members.Member
  alias Basic.Orders
  alias Basic.Orders.Order
  alias Basic.Addresses
  alias Basic.Addresses.Address
  alias Basic.Items
  alias Basic.Deliveries

  @impl true
  def mount(params, session, socket) do
    current_user_id = case session["account_token"] do
      nil -> ""
      token -> Accounts.get_account_by_session_token(token).id
    end

    member_info = case current_user_id do
      "" -> nil
      _ -> List.first(Members.get_member_from_user_id(current_user_id))
    end

    address = case current_user_id do
      "" -> []
      _ ->
        case Map.has_key?(params, "id") do
          true ->
            Addresses.list_addresses_selected(current_user_id, params["id"])
          false ->
            Addresses.list_addresses_for_user(current_user_id)
        end
    end

    register_params = %{}
    case member_info do
      nil ->
        case address do
          [] ->
            {:ok,
            socket
            |> assign(:carts, Carts.list_carts_for_user(current_user_id))
            |> assign(:current_user_id, current_user_id)
            |> assign(:address, address)
            |> assign(:params, register_params |> Map.put_new("last_name", "")
                                               |> Map.put_new("first_name", "")
                                               |> Map.put_new("postal", "")
                                               |> Map.put_new("prefecture", "")
                                               |> Map.put_new("city", "")
                                               |> Map.put_new("address1", "")
                                               |> Map.put_new("address2", "")
                                               |> Map.put_new("tel", "")
                                               |> Map.put_new("payment_method", "")
                    )
            }
          _ ->
            {:ok,
            socket
            |> assign(:carts, Carts.list_carts_for_user(current_user_id))
            |> assign(:current_user_id, current_user_id)
            |> assign(:address, address)
            |> assign(:params, register_params |> Map.put_new("last_name", List.first(address).last_name)
                                               |> Map.put_new("first_name", List.first(address).first_name)
                                               |> Map.put_new("postal", List.first(address).postal)
                                               |> Map.put_new("prefecture", List.first(address).prefecture)
                                               |> Map.put_new("city", List.first(address).city)
                                               |> Map.put_new("address1", List.first(address).address1)
                                               |> Map.put_new("address2", List.first(address).address2)
                                               |> Map.put_new("tel", List.first(address).tel)
                                               |> Map.put_new("payment_method", "")
                    )
            }
        end
      _ ->
        case address do
          [] ->
            {:ok,
            socket
            |> assign(:carts, Carts.list_carts_for_user(current_user_id))
            |> assign(:current_user_id, current_user_id)
            |> assign(:address, address)
            |> assign(:params, register_params |> Map.put_new("last_name", member_info.last_name)
                                               |> Map.put_new("first_name", member_info.first_name)
                                               |> Map.put_new("postal", "")
                                               |> Map.put_new("prefecture", "")
                                               |> Map.put_new("city", "")
                                               |> Map.put_new("address1", "")
                                               |> Map.put_new("address2", "")
                                               |> Map.put_new("tel", "")
                                               |> Map.put_new("payment_method", "")
                    )
            }
          _ ->
            {:ok,
            socket
            |> assign(:carts, Carts.list_carts_for_user(current_user_id))
            |> assign(:current_user_id, current_user_id)
            |> assign(:address, address)
            |> assign(:params, register_params |> Map.put_new("last_name", List.first(address).last_name)
                                               |> Map.put_new("first_name", List.first(address).first_name)
                                               |> Map.put_new("postal", List.first(address).postal)
                                               |> Map.put_new("prefecture", List.first(address).prefecture)
                                               |> Map.put_new("city", List.first(address).city)
                                               |> Map.put_new("address1", List.first(address).address1)
                                               |> Map.put_new("address2", List.first(address).address2)
                                               |> Map.put_new("tel", List.first(address).tel)
                                               |> Map.put_new("payment_method", "")
                    )
            }
        end
    end
  end

  @impl true
  def handle_params(params, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, "レジ")}
  end

  @impl true
  def handle_event("submit", register_params, socket) do
    case validate_params(register_params) do
      false ->
        {:noreply, put_flash(socket, :error, "入力内容に不足があります")}
      true ->
        case Addresses.registered_address_id(register_params) do
          -1 ->     #登録なし住所
            case Addresses.create_address(register_params) do
              {:ok, address} ->
                List.first(create_order(socket, register_params, address.id))

              {:error, %Ecto.Changeset{} = changeset} ->
                {:noreply, put_flash(socket, :error, "入力内容を見直してください")}
            end
          id ->
            List.first(create_order(socket, register_params, id))
        end

    end
  end

  def get_order_number(current_user_id, now) do
    String.replace(String.pad_leading(Integer.to_string(now.second), 2), " ", "0")
      <> Integer.to_string(div(now.minute, 10))
      <> "-"
      <> Integer.to_string(rem(now.minute, 10))
      <> String.replace(String.pad_leading(Integer.to_string(current_user_id), 5), " ", "0")
      <> Integer.to_string(div(now.hour, 10))
      <> "-"
      <> Integer.to_string(rem(now.hour, 10))
      <> String.replace(String.pad_leading(Integer.to_string(now.day), 2), " ", "0")
      <> String.replace(String.pad_leading(Integer.to_string(now.month), 2), " ", "0")
  end

  def validate_params(register_params) do
    case register_params["last_name"] do
      "" -> false
      _ ->
        case register_params["prefecture"] do
          "" -> false
          _ ->
            case register_params["city"] do
              "" -> false
              _ ->
                case register_params["address1"] do
                  "" -> false
                  _ ->
                    case register_params["payment_method"] do
                      "" -> false
                      _ -> true
                    end
                end
            end
        end
    end
  end

  def create_order(socket, params, address_id) do
    order_params = %{}
    delivery_params = %{}

    now = NaiveDateTime.utc_now
    order_number = get_order_number(socket.assigns.current_user_id, now)

    for cart <- socket.assigns.carts do
      item = Items.get_item!(List.first(cart).item_id)
      stocks = case item.stocks do
        nil -> nil
        _   -> item.stocks - List.first(cart).quantity
      end
      case Items.update_item(item, Map.from_struct(Map.put(item, :stocks, stocks))) do
        {:ok, _item} ->
          case Orders.create_order(order_params
                                    |> Map.put_new(:user_id, socket.assigns.current_user_id)
                                    |> Map.put_new(:item_id, List.first(cart).item_id)
                                    |> Map.put_new(:price, item.price * List.first(cart).quantity)
                                    |> Map.put_new(:order_date, now)
                                    |> Map.put_new(:order_number, order_number)
                                    |> Map.put_new(:discount, 0)
                                    |> Map.put_new(:is_cancel, false)
                                    |> Map.put_new(:deleted_at, ~N[2016-01-01 00:00:00.000000])) do
            {:ok, order} ->
              case Carts.update_cart(Carts.get_cart!(List.first(cart).id), Map.put(List.first(cart), :is_order, true)) do
                {:ok, _cart} ->
                  case Deliveries.create_delivery(delivery_params
                                                  |> Map.put_new(:order_id, order.id)
                                                  |> Map.put_new(:address_id, address_id)
                                                  |> Map.put_new(:phase, "準備中")
                                                  |> Map.put_new(:order_number, order_number)) do
                    {:ok, _delivery} ->
                      {:noreply,
                        socket
                        |> put_flash(:info, "注文を受け付けました")
                        |> push_redirect(to: Routes.item_ui_index_path(socket, :index))}

                    {:error, %Ecto.Changeset{} = changeset} ->
                      {:noreply, assign(socket, changeset: changeset)}
                  end

                {:error, %Ecto.Changeset{} = changeset} ->
                  {:noreply, assign(socket, changeset: changeset)}
              end

            {:error, %Ecto.Changeset{} = changeset} ->
              {:noreply, assign(socket, changeset: changeset)}
          end

        {:error, %Ecto.Changeset{} = changeset} ->
          {:noreply, assign(socket, changeset: changeset)}
      end
    end
  end
end
