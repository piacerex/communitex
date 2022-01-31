defmodule BasicWeb.AddressUiLive.Index do
  use BasicWeb, :live_view

  alias Basic.Addresses
  alias Basic.Addresses.Address
  alias Basic.Accounts

  @impl true
  def mount(_params, session, socket) do
    current_user_id = case session["account_token"] do
      nil -> ""
      token -> Accounts.get_account_by_session_token(token).id
    end
    {:ok,
     socket
     |> assign(:addresses, Addresses.list_addresses_for_user(current_user_id))
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Address")
    |> assign(:address, Addresses.get_address!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Address")
    |> assign(:address, %Address{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Addresses")
    |> assign(:address, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    address = Addresses.get_address!(id)
    {:ok, _} = Addresses.delete_address(address)

    {:noreply, assign(socket, :addresses, list_addresses())}
  end

  defp list_addresses do
    Addresses.list_addresses()
  end
end
