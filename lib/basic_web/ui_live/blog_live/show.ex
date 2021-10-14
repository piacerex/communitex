defmodule BasicWeb.BlogUiLive.Show do
  use BasicWeb, :live_view

  alias Basic.Blogs
  alias Basic.Accounts

  @impl true
  def mount(_params, session, socket) do
    current_user_id = case session["user_token"] do
      nil -> ""
      token -> Accounts.get_user_by_session_token(token).id
    end
    {:ok,
      socket
      |> assign(:current_user_id, current_user_id)
    }
  end

  @impl true
  def handle_params(%{"post_id" => post_id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:blog, Blogs.get_blog_by_post_id!(post_id))}
  end

  defp page_title(:show), do: "Show Blog"
  defp page_title(:edit), do: "Edit Blog"
end
