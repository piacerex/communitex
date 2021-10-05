defmodule BasicWeb.GrantLive.Index do
  use BasicWeb, :live_view

  alias Basic.Grants
  alias Basic.Grants.Grant
  alias Basic.Organizations
  alias Basic.Organizations.Organization
  alias Basic.Accounts
  alias Basic.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    {:ok, 
      socket
      |> assign(:grants, list_grants())
      |> assign(:organizations, Organizations.list_organizations())
      |> assign(:role_list, Grants.get_role_list(current_user.id))
      |> assign(:search, "")
      |> assign(:candidate, [])
    }
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
    |> assign(:grant, [%Grant{}, %User{}, %Organization{}])
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Grants")
    |> assign(:grant, nil)
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, assign(socket, :candidate, Grants.search_user(search))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    grant = Grants.get_grant!(id)
    {:ok, _} = Grants.delete_grant(List.first(grant))

    {:noreply, assign(socket, :grants, list_grants())}
  end

  defp list_grants do
    Grants.list_grants()
  end
end
