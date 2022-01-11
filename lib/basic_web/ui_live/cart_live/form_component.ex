defmodule BasicWeb.CartUiLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Carts
  alias Basic.Items

  @impl true
  def update(%{cart: cart} = assigns, socket) do
    changeset = Carts.change_cart(cart)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"cart" => cart_params}, socket) do
    changeset =
      socket.assigns.cart
      |> Carts.change_cart(cart_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"cart" => cart_params}, socket) do
    save_cart(socket, socket.assigns.action, cart_params)
  end

  defp save_cart(socket, :edit, cart_params) do
    item_stocks = Items.get_item!(String.to_integer(cart_params["item_id"])).stocks

    case String.to_integer(cart_params["quantity"]) > item_stocks do
      false ->
        case Carts.update_cart(socket.assigns.cart, cart_params) do
          {:ok, _cart} ->
            {:noreply,
              socket
              |> put_flash(:info, "カートを更新しました")
              |> push_redirect(to: socket.assigns.return_to)
            }

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, :changeset, changeset)}
        end
      true ->
        {:noreply,
          socket
          |> put_flash(:error, "注文数が在庫数を超えています")
          |> push_redirect(to: socket.assigns.return_to)
        }
end
  end

  defp save_cart(socket, :new, cart_params) do
    case Carts.create_cart(cart_params) do
      {:ok, _cart} ->
        {:noreply,
         socket
         |> put_flash(:info, "Cart created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
