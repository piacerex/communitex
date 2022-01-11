defmodule BasicWeb.CartLive.Show do
  use BasicWeb, :live_view

  alias Basic.Carts

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:cart, Carts.get_cart!(id))}
  end

  defp page_title(:show), do: "Show Cart"
  defp page_title(:edit), do: "Edit Cart"
end
