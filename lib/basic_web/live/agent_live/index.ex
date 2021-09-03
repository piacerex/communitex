defmodule BasicWeb.AgentLive.Index do
  use BasicWeb, :live_view

  alias Basic.Agents
  alias Basic.Agents.Agent
  alias Basic.Accounts

  @impl true
#  def mount(_params, _session, socket) do
#    {:ok, assign(socket, :agents, list_agents())}
#  end
  def mount(params, session, socket) do
    a_id = if Map.has_key?(params, "agency_id") do
      String.to_integer(params["agency_id"])
    else
      ""
    end

    current_user = Accounts.get_user_by_session_token(session["user_token"])
    {:ok, 
      socket
      |> assign(:current_user_id, current_user.id)
      |> assign(:agents, Agents.select_agents(current_user.id, a_id))
      |> assign(:agencies, Agents.get_relate_agancies(current_user.id))
      |> assign(:selected_agency, a_id)
      |> assign(:search, "")
      |> assign(:candidate, "")
    }
  end

  def handle_event("search", %{"search" => search} = params, socket) do
    {:noreply, assign(socket, :candidate, Agents.search_user(search))}
  end

  @impl true
  def handle_event("validate", %{"survey" => params}, socket) do
    case params["agency_id"] do
      "" ->
        {:noreply, socket}

      choice ->
        {:noreply, 
          socket
          |> assign(:selected_agency, params["agency_id"])
          |> assign(:agents, Agents.select_agents(socket.assigns.current_user_id, String.to_integer(params["agency_id"])))
          |> push_patch(to: "/agents" <> "?agency_id=" <> params["agency_id"], replace: true)
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
    |> assign(:agencies, Agents.get_relate_agancies(socket.assigns.current_user_id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Agent")
    |> assign(:agent, %Agent{})
    |> assign(:current_user_id, socket.assigns.current_user_id)
    |> assign(:agencies, Agents.get_relate_agancies(socket.assigns.current_user_id))
    |> assign(:selected_agency, "")
    |> assign(:search, "")
    |> assign(:candidate, "")
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Agents")
    |> assign(:agent, nil)
    |> assign(:agencies, Agents.get_relate_agancies(socket.assigns.current_user_id))
    |> assign(:search, "")
    |> assign(:candidate, "")
  end

  @impl true
#  def handle_event("delete", %{"id" => id}, socket) do
#    agent = Agents.get_agent!(id)
#    {:ok, _} = Agents.delete_agent(agent)
#
#    {:noreply, assign(socket, :agents, list_agents())}
#  end
  def handle_event("delete", %{"id" => id}, socket) do
    agent = Agents.get_delete_agent!(id)
    {:ok, _} = Agents.delete_agent(agent)

    {:noreply, 
      socket
      |> assign(:current_user_id, socket.assigns.current_user_id)
      |> assign(:agents, Agents.select_agents(socket.assigns.current_user_id, ""))
      |> assign(:agencies, Agents.get_relate_agancies(socket.assigns.current_user_id))
      |> assign(:selected_agency, "")
      |> assign(:search, "")
      |> assign(:candidate, "")
    }
  end

  defp list_agents do
    Agents.list_agents()
  end
end
