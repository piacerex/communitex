defmodule BasicWeb.AgentLive.Index do
  use BasicWeb, :live_view

  alias Basic.Agents
  alias Basic.Agents.Agent
  alias Basic.Accounts
  alias Basic.Agencies

  @impl true
  def mount(params, session, socket) do
    agency_id = case Map.has_key?(params, "agency_id") do
      true -> String.to_integer(params["agency_id"])
      _ -> ""
    end

    current_user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    {:ok, 
      socket
      |> assign(:current_user_id, current_user_id)
      |> assign(:agents, Agents.get_selected_agents(current_user_id, agency_id))
      |> assign(:agencies, Agents.get_granted_agencies(current_user_id))
      |> assign(:selected_agency, agency_id)
      |> assign(:search, "")
      |> assign(:candidate_users, "")
    }
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    agent = Agents.get_delete_agent!(id)
    {:ok, _} = Agents.delete_agent(agent)

    {:noreply, 
      socket
      |> assign(:current_user_id, socket.assigns.current_user_id)
      |> assign(:agents, Agents.get_selected_agents(socket.assigns.current_user_id, ""))
      |> assign(:agencies, Agents.get_granted_agencies(socket.assigns.current_user_id))
      |> assign(:selected_agency, "")
      |> assign(:search, "")
      |> assign(:candidate_users, "")
    }
  end

  @impl true
  def handle_event("search", %{"search" => search}, socket) do
    {:noreply, assign(socket, :candidate_users, Agents.search_users(search))}
  end

  @impl true
  def handle_event("validate", %{"choice" => params}, socket) do
    case params["agency_id"] do
      "" ->
        {:noreply, socket}

      _ ->
        {:noreply, 
          socket
          |> assign(:selected_agency, String.to_integer(params["agency_id"]))
          |> assign(:agents, Agents.get_selected_agents(socket.assigns.current_user_id, String.to_integer(params["agency_id"])))
          |> push_patch(to: "/admin/agents" <> "?agency_id=" <> params["agency_id"], replace: true)
        }
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Agent")
    |> assign(:agent, List.first(Agents.get_agent!(id)))
    |> assign(:agencies, Agents.get_granted_agencies(socket.assigns.current_user_id))
  end

  defp apply_action(socket, :new, _params) do
    selected_agency_data = Agencies.get_agency!(socket.assigns.selected_agency)
    display_data = %Agent{}
                   |> Map.put(:agency_id, selected_agency_data.id)
                   |> Map.put(:boost, selected_agency_data.boost)
                   |> Map.put(:discount, selected_agency_data.discount)

    socket
    |> assign(:page_title, "New Agent")
    |> assign(:agent, display_data)
    |> assign(:current_user_id, socket.assigns.current_user_id)
    |> assign(:agencies, Agents.get_granted_agencies(socket.assigns.current_user_id))
    |> assign(:selected_agency, socket.assigns.selected_agency)
    |> assign(:search, "")
    |> assign(:candidate_users, "")
  end

  defp apply_action(socket, :index, _params) do
    case socket.assigns.selected_agency do
      [] ->
        socket
        |> assign(:page_title, "Listing Agents")
      _ ->
        socket
        |> assign(:page_title, "Listing Agents")
        |> assign(:agent, nil)
        |> assign(:agencies, Agents.get_granted_agencies(socket.assigns.current_user_id))
        |> assign(:search, "")
        |> assign(:candidate_users, "")
    end
  end

#  defp list_agents do
#    Agents.list_agents()
#  end
end
