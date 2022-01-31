defmodule BasicWeb.GrantLive.Show do
  use BasicWeb, :live_view

  alias Basic.Grants
  alias Basic.Organizations
  alias Basic.Accounts

  @impl true
  def mount(_params, session, socket) do
    current_user = Accounts.get_account_by_session_token(session["account_token"])
    organizations = Grants.get_registrable_organizations(current_user.id)
    {:ok,
      socket
      |> assign(:organizations, organizations)
      |> assign(:all_roles, Grants.roles())
      |> assign(:role_list, Grants.get_role_list(current_user.id, List.first(organizations).id))
    }
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:grant, Grants.get_grant!(id))
    }
  end

  defp page_title(:show), do: "Show Grant"
  defp page_title(:edit), do: "Edit Grant"
end
