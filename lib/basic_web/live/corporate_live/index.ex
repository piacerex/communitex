defmodule BasicWeb.CorporateLive.Index do
  use BasicWeb, :live_view

  alias Basic.Corporates
  alias Basic.Corporates.Corporate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :corporates, list_corporates())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Corporate")
    |> assign(:corporate, Corporates.get_corporate!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Corporate")
    |> assign(:corporate, %Corporate{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Corporates")
    |> assign(:corporate, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    corporate = Corporates.get_corporate!(id)
    {:ok, _} = Corporates.delete_corporate(corporate)

    {:noreply, assign(socket, :corporates, list_corporates())}
  end

  defp list_corporates do
    Corporates.list_corporates()
  end
end
