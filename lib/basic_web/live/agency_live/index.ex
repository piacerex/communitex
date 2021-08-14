defmodule BasicWeb.AgencyLive.Index do
  use BasicWeb, :live_view

  alias Basic.Agencies
  alias Basic.Agencies.Agency

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :agencies, list_agencies())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Agency")
    |> assign(:agency, Agencies.get_agency!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Agency")
    |> assign(:agency, %Agency{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Agencies")
    |> assign(:agency, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    agency = Agencies.get_agency!(id)
    {:ok, _} = Agencies.delete_agency(agency)

    {:noreply, assign(socket, :agencies, list_agencies())}
  end

  defp list_agencies do
    Agencies.list_agencies()
  end
end
