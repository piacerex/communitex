defmodule BasicWeb.AgentLive.FormComponent do
  use BasicWeb, :live_component

  alias Basic.Agents

  @impl true
  def update(%{agent: agent} = assigns, socket) do
    changeset = case is_map(agent) do
      true -> Agents.change_agent(agent)
      _ -> Agents.change_agent(List.first(agent))
    end

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"agent" => agent_params}, socket) do
    candidate_users = case agent_params["search"] do
      "" -> ""
      _  -> Agents.search_users(agent_params["search"])
    end

    changeset =
      socket.assigns.agent
      |> Agents.change_agent(agent_params)
      |> Map.put(:action, :validate)

    {:noreply,
      socket
      |> assign(:changeset, changeset)
      |> assign(:candidate_users, candidate_users)
    }
  end

  def handle_event("save", %{"agent" => agent_params}, socket) do
    save_agent(socket, socket.assigns.action, agent_params)
  end

  defp save_agent(socket, :edit, agent_params) do
    case Agents.update_agent(socket.assigns.agent, agent_params) do
      {:ok, _agent} ->
        {:noreply,
         socket
         |> put_flash(:info, "Agent updated successfully")
         |> push_redirect(to: socket.assigns.return_to <> "?agency_id=" <> agent_params["agency_id"])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_agent(socket, :new, agent_params) do
    case Agents.create_agent(agent_params) do
      {:ok, _agent} ->
        {:noreply,
         socket
         |> assign(:agents, Agents.get_selected_agents(socket.assigns.current_user_id, String.to_integer(agent_params["agency_id"])))
         |> assign(:selected_agency, String.to_integer(agent_params["agency_id"]))
         |> put_flash(:info, "Agent created successfully")
         |> push_redirect(to: socket.assigns.return_to <> "?agency_id=" <> agent_params["agency_id"])}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
