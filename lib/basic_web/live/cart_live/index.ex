defmodule BasicWeb.CartLive.Index do
  use BasicWeb, :live_view

  alias Basic.Carts
  alias Basic.Carts.Cart

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :carts, list_carts())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Cart")
    |> assign(:cart, Carts.get_cart!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Cart")
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

    {:noreply, assign(socket, :carts, list_carts())}
  end

  defp list_carts do
    Carts.list_carts()
  end
end
