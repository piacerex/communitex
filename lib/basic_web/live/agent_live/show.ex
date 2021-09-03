defmodule BasicWeb.AgentLive.Show do
  use BasicWeb, :live_view

  alias Basic.Agents
  alias Basic.Accounts

  @impl true
#  def mount(_params, _session, socket) do
#    {:ok, socket}
#  end
  def mount(_params, session, socket) do
    current_user = Accounts.get_user_by_session_token(session["user_token"])
    {:ok, assign(socket, :agencies, Agents.get_relate_agancies(current_user.id))}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:agent, List.first(Agents.get_agent!(id)))}
  end

  defp page_title(:show), do: "Show Agent"
  defp page_title(:edit), do: "Edit Agent"
end
