defmodule BasicWeb.MemberLive.Index do
  use BasicWeb, :live_view

  alias Basic.Members
  alias Basic.Members.Member

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, members: list_members())}
  end

  def handle_event("nav", %{"page" => page}, socket) do
    {:noreply, push_redirect(socket, to: Routes.member_index_path(socket, :index, page: page))}
  end

  def handle_params(params, _, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  def assign_pagination(%{"page" => page}), do: get_and_assign_page(page)
  def assign_pagination(_), do: get_and_assign_page(nil)

  def get_and_assign_page(page_number) do
    %{
      entries: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    } = Members.paginate_members(page: page_number)

    [
      members: entries,
      page_number: page_number,
      page_size: page_size,
      total_entries: total_entries,
      total_pages: total_pages
    ]
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Member")
    |> assign(:member, List.first(Members.get_member!(id)))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Member")
    |> assign(:member, %Member{})
  end

  defp apply_action(socket, :index, params) do
    socket
    |> assign(:page_title, "Listing Members")
    |> assign(assign_pagination(params))
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
#    member = Members.get_member!(id)
    member = Members.get_delete_member!(id)
    {:ok, _} = Members.delete_member(member)

      {:noreply, assign(socket, :members, list_members())}
  end

  defp list_members do
    Members.list_members()
  end
end
