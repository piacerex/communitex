defmodule BasicWeb.GrantLive.Index do
  use BasicWeb, :live_view

  alias Basic.Grants
  alias Basic.Grants.Grant

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :grants, list_grants())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Grant")
    |> assign(:grant, Grants.get_grant!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Grant")
    |> assign(:grant, %Grant{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Grants")
    |> assign(:grant, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    grant = Grants.get_grant!(id)
    {:ok, _} = Grants.delete_grant(grant)

    {:noreply, assign(socket, :grants, list_grants())}
  end

  defp list_grants do
    Grants.list_grants()
  end
end
