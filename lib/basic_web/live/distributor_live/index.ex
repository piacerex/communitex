defmodule BasicWeb.DistributorLive.Index do
  use BasicWeb, :live_view

  alias Basic.Distributors
  alias Basic.Distributors.Distributor

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :distributors, list_distributors())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Distributor")
    |> assign(:distributor, Distributors.get_distributor!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Distributor")
    |> assign(:distributor, %Distributor{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Distributors")
    |> assign(:distributor, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    distributor = Distributors.get_distributor!(id)
    {:ok, _} = Distributors.delete_distributor(distributor)

    {:noreply, assign(socket, :distributors, list_distributors())}
  end

  defp list_distributors do
    Distributors.list_distributors()
  end
end
