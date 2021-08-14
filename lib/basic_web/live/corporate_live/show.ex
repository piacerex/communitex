defmodule BasicWeb.CorporateLive.Show do
  use BasicWeb, :live_view

  alias Basic.Corporates

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:corporate, Corporates.get_corporate!(id))}
  end

  defp page_title(:show), do: "Show Corporate"
  defp page_title(:edit), do: "Edit Corporate"
end
