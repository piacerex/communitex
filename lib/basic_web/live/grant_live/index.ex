defmodule BasicWeb.GrantLive.Index do
  use BasicWeb, :live_view

  alias Basic.Grants
  alias Basic.Grants.Grant
  alias Basic.Organizations.Organization
  alias Basic.Accounts
  alias Basic.Accounts.User

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    organizations = Grants.get_registrable_organizations(current_user.id)

    role_list = case organizations do
      [] -> []
      _  -> Grants.get_role_list(current_user.id, List.first(organizations).id)
    end

    {:ok, 
      socket
      |> assign(:current_user_id, current_user.id)
      |> assign(:grants, Grants.list_grants(current_user.id))
      |> assign(:organizations, organizations)
      |> assign(:all_roles, Grants.roles())
      |> assign(:role_list, role_list)
      |> assign(:candidate_users, [])
      |> assign(:selected_organization, "")
      |> assign(:selected_user, "")
    }
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

#  defp apply_action(socket, :edit, %{"id" => id}) do
#    socket
#    |> assign(:page_title, "Edit Grant")
#    |> assign(:grant, Grants.get_grant!(id))
#  end

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
  def handle_event("delete", %{"id" => id}, socket) do
    grant = Grants.get_grant!(id)
    {:ok, _} = Grants.delete_grant(List.first(grant))

    {:noreply, assign(socket, :grants, Grants.list_grants(socket.assigns.current_user_id))}
  end

  defp list_grants do
    Grants.list_grants()
  end
end
