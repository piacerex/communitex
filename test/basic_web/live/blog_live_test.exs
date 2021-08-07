defmodule BasicWeb.BlogLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Basic.Blogs

  @create_attrs %{body: "some body", deleted_at: ~N[2010-04-17 14:00:00], image: "some image", likes: 42, post_id: "some post_id", tags: "some tags", title: "some title", user_id: 42, views: 42}
  @update_attrs %{body: "some updated body", deleted_at: ~N[2011-05-18 15:01:01], image: "some updated image", likes: 43, post_id: "some updated post_id", tags: "some updated tags", title: "some updated title", user_id: 43, views: 43}
  @invalid_attrs %{body: nil, deleted_at: nil, image: nil, likes: nil, post_id: nil, tags: nil, title: nil, user_id: nil, views: nil}

  defp fixture(:blog) do
    {:ok, blog} = Blogs.create_blog(@create_attrs)
    blog
  end

  defp create_blog(_) do
    blog = fixture(:blog)
    %{blog: blog}
  end

  describe "Index" do
    setup [:create_blog]

    test "lists all blogs", %{conn: conn, blog: blog} do
      {:ok, _index_live, html} = live(conn, Routes.blog_index_path(conn, :index))

      assert html =~ "Listing Blogs"
      assert html =~ blog.body
    end

    test "saves new blog", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.blog_index_path(conn, :index))

      assert index_live |> element("a", "New Blog") |> render_click() =~
               "New Blog"

      assert_patch(index_live, Routes.blog_index_path(conn, :new))

      assert index_live
             |> form("#blog-form", blog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#blog-form", blog: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.blog_index_path(conn, :index))

      assert html =~ "Blog created successfully"
      assert html =~ "some body"
    end

    test "updates blog in listing", %{conn: conn, blog: blog} do
      {:ok, index_live, _html} = live(conn, Routes.blog_index_path(conn, :index))

      assert index_live |> element("#blog-#{blog.id} a", "Edit") |> render_click() =~
               "Edit Blog"

      assert_patch(index_live, Routes.blog_index_path(conn, :edit, blog))

      assert index_live
             |> form("#blog-form", blog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#blog-form", blog: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.blog_index_path(conn, :index))

      assert html =~ "Blog updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes blog in listing", %{conn: conn, blog: blog} do
      {:ok, index_live, _html} = live(conn, Routes.blog_index_path(conn, :index))

      assert index_live |> element("#blog-#{blog.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#blog-#{blog.id}")
    end
  end

  describe "Show" do
    setup [:create_blog]

    test "displays blog", %{conn: conn, blog: blog} do
      {:ok, _show_live, html} = live(conn, Routes.blog_show_path(conn, :show, blog))

      assert html =~ "Show Blog"
      assert html =~ blog.body
    end

    test "updates blog within modal", %{conn: conn, blog: blog} do
      {:ok, show_live, _html} = live(conn, Routes.blog_show_path(conn, :show, blog))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Blog"

      assert_patch(show_live, Routes.blog_show_path(conn, :edit, blog))

      assert show_live
             |> form("#blog-form", blog: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#blog-form", blog: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.blog_show_path(conn, :show, blog))

      assert html =~ "Blog updated successfully"
      assert html =~ "some updated body"
    end
  end
end
