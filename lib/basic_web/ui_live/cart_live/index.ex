defmodule BasicWeb.CartUiLive.Index do
  use BasicWeb, :live_view

  alias Basic.Carts
  alias Basic.Carts.Cart
  alias Basic.Accounts

    @impl true
  def mount(_params, session, socket) do
    register = %{last_name: nil,
                 first_name: nil,
                 postal: nil,
                 address: nil,
                 payment_method: nil
                 }
    current_user_id = case session["user_token"] do
      nil -> ""
      token -> Accounts.get_user_by_session_token(token).id
    end
    {:ok,
      socket
      |> assign(:carts, Carts.list_carts_for_user(current_user_id))
      |> assign(:current_user_id, current_user_id)
      |> assign(:register, register)
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :register, params) do
    socket
    |> assign(:page_title, "レジ")
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "注文の変更")
    |> assign(:cart, Carts.get_cart!(id))
    |> assign(:item_name, Carts.get_item_name(id))
  end

  defp apply_action(socket, :new, params) do
    socket
    |> assign(:page_title, "New Carts")
    |> assign(:cart, %Cart{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Carts")
    |> assign(:cart, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    cart = Carts.get_cart!(id)
    {:ok, _} = Carts.delete_cart(cart)

    {:noreply,
      socket
      |> assign(:carts, Carts.list_carts_for_user(socket.assigns.current_user_id))
      |> assign(:current_user_id, socket.assigns.current_user_id)
      |> assign(:register, socket.assigns.register)
    }
end

  defp list_carts do
    Carts.list_carts()
  end
end
