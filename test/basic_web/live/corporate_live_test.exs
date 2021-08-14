defmodule BasicWeb.CorporateLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Basic.Corporates

  @create_attrs %{address1: "some address1", address2: "some address2", city: "some city", deleted_at: ~N[2010-04-17 14:00:00], name: "some name", postal: "some postal", prefecture: "some prefecture", tel: "some tel"}
  @update_attrs %{address1: "some updated address1", address2: "some updated address2", city: "some updated city", deleted_at: ~N[2011-05-18 15:01:01], name: "some updated name", postal: "some updated postal", prefecture: "some updated prefecture", tel: "some updated tel"}
  @invalid_attrs %{address1: nil, address2: nil, city: nil, deleted_at: nil, name: nil, postal: nil, prefecture: nil, tel: nil}

  defp fixture(:corporate) do
    {:ok, corporate} = Corporates.create_corporate(@create_attrs)
    corporate
  end

  defp create_corporate(_) do
    corporate = fixture(:corporate)
    %{corporate: corporate}
  end

  describe "Index" do
    setup [:create_corporate]

    test "lists all corporates", %{conn: conn, corporate: corporate} do
      {:ok, _index_live, html} = live(conn, Routes.corporate_index_path(conn, :index))

      assert html =~ "Listing Corporates"
      assert html =~ corporate.address1
    end

    test "saves new corporate", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.corporate_index_path(conn, :index))

      assert index_live |> element("a", "New Corporate") |> render_click() =~
               "New Corporate"

      assert_patch(index_live, Routes.corporate_index_path(conn, :new))

      assert index_live
             |> form("#corporate-form", corporate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#corporate-form", corporate: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.corporate_index_path(conn, :index))

      assert html =~ "Corporate created successfully"
      assert html =~ "some address1"
    end

    test "updates corporate in listing", %{conn: conn, corporate: corporate} do
      {:ok, index_live, _html} = live(conn, Routes.corporate_index_path(conn, :index))

      assert index_live |> element("#corporate-#{corporate.id} a", "Edit") |> render_click() =~
               "Edit Corporate"

      assert_patch(index_live, Routes.corporate_index_path(conn, :edit, corporate))

      assert index_live
             |> form("#corporate-form", corporate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#corporate-form", corporate: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.corporate_index_path(conn, :index))

      assert html =~ "Corporate updated successfully"
      assert html =~ "some updated address1"
    end

    test "deletes corporate in listing", %{conn: conn, corporate: corporate} do
      {:ok, index_live, _html} = live(conn, Routes.corporate_index_path(conn, :index))

      assert index_live |> element("#corporate-#{corporate.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#corporate-#{corporate.id}")
    end
  end

  describe "Show" do
    setup [:create_corporate]

    test "displays corporate", %{conn: conn, corporate: corporate} do
      {:ok, _show_live, html} = live(conn, Routes.corporate_show_path(conn, :show, corporate))

      assert html =~ "Show Corporate"
      assert html =~ corporate.address1
    end

    test "updates corporate within modal", %{conn: conn, corporate: corporate} do
      {:ok, show_live, _html} = live(conn, Routes.corporate_show_path(conn, :show, corporate))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Corporate"

      assert_patch(show_live, Routes.corporate_show_path(conn, :edit, corporate))

      assert show_live
             |> form("#corporate-form", corporate: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#corporate-form", corporate: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.corporate_show_path(conn, :show, corporate))

      assert html =~ "Corporate updated successfully"
      assert html =~ "some updated address1"
    end
  end
end
