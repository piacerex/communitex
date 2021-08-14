defmodule BasicWeb.GrantLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Basic.Grants

  @create_attrs %{corporate_id: 42, deleted_at: ~N[2010-04-17 14:00:00], role: "some role", user_id: 42}
  @update_attrs %{corporate_id: 43, deleted_at: ~N[2011-05-18 15:01:01], role: "some updated role", user_id: 43}
  @invalid_attrs %{corporate_id: nil, deleted_at: nil, role: nil, user_id: nil}

  defp fixture(:grant) do
    {:ok, grant} = Grants.create_grant(@create_attrs)
    grant
  end

  defp create_grant(_) do
    grant = fixture(:grant)
    %{grant: grant}
  end

  describe "Index" do
    setup [:create_grant]

    test "lists all grants", %{conn: conn, grant: grant} do
      {:ok, _index_live, html} = live(conn, Routes.grant_index_path(conn, :index))

      assert html =~ "Listing Grants"
      assert html =~ grant.role
    end

    test "saves new grant", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.grant_index_path(conn, :index))

      assert index_live |> element("a", "New Grant") |> render_click() =~
               "New Grant"

      assert_patch(index_live, Routes.grant_index_path(conn, :new))

      assert index_live
             |> form("#grant-form", grant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#grant-form", grant: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.grant_index_path(conn, :index))

      assert html =~ "Grant created successfully"
      assert html =~ "some role"
    end

    test "updates grant in listing", %{conn: conn, grant: grant} do
      {:ok, index_live, _html} = live(conn, Routes.grant_index_path(conn, :index))

      assert index_live |> element("#grant-#{grant.id} a", "Edit") |> render_click() =~
               "Edit Grant"

      assert_patch(index_live, Routes.grant_index_path(conn, :edit, grant))

      assert index_live
             |> form("#grant-form", grant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#grant-form", grant: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.grant_index_path(conn, :index))

      assert html =~ "Grant updated successfully"
      assert html =~ "some updated role"
    end

    test "deletes grant in listing", %{conn: conn, grant: grant} do
      {:ok, index_live, _html} = live(conn, Routes.grant_index_path(conn, :index))

      assert index_live |> element("#grant-#{grant.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#grant-#{grant.id}")
    end
  end

  describe "Show" do
    setup [:create_grant]

    test "displays grant", %{conn: conn, grant: grant} do
      {:ok, _show_live, html} = live(conn, Routes.grant_show_path(conn, :show, grant))

      assert html =~ "Show Grant"
      assert html =~ grant.role
    end

    test "updates grant within modal", %{conn: conn, grant: grant} do
      {:ok, show_live, _html} = live(conn, Routes.grant_show_path(conn, :show, grant))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Grant"

      assert_patch(show_live, Routes.grant_show_path(conn, :edit, grant))

      assert show_live
             |> form("#grant-form", grant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#grant-form", grant: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.grant_show_path(conn, :show, grant))

      assert html =~ "Grant updated successfully"
      assert html =~ "some updated role"
    end
  end
end
