defmodule BasicWeb.DistributorLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Basic.DistributorsFixtures

  @create_attrs %{brand: "some brand", deleted_at: %{day: 12, hour: 1, minute: 49, month: 1, year: 2022}, organization_id: 42}
  @update_attrs %{brand: "some updated brand", deleted_at: %{day: 13, hour: 1, minute: 49, month: 1, year: 2022}, organization_id: 43}
  @invalid_attrs %{brand: nil, deleted_at: %{day: 30, hour: 1, minute: 49, month: 2, year: 2022}, organization_id: nil}

  defp create_distributor(_) do
    distributor = distributor_fixture()
    %{distributor: distributor}
  end

  describe "Index" do
    setup [:create_distributor]

    test "lists all distributors", %{conn: conn, distributor: distributor} do
      {:ok, _index_live, html} = live(conn, Routes.distributor_index_path(conn, :index))

      assert html =~ "Listing Distributors"
      assert html =~ distributor.brand
    end

    test "saves new distributor", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.distributor_index_path(conn, :index))

      assert index_live |> element("a", "New Distributor") |> render_click() =~
               "New Distributor"

      assert_patch(index_live, Routes.distributor_index_path(conn, :new))

      assert index_live
             |> form("#distributor-form", distributor: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#distributor-form", distributor: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.distributor_index_path(conn, :index))

      assert html =~ "Distributor created successfully"
      assert html =~ "some brand"
    end

    test "updates distributor in listing", %{conn: conn, distributor: distributor} do
      {:ok, index_live, _html} = live(conn, Routes.distributor_index_path(conn, :index))

      assert index_live |> element("#distributor-#{distributor.id} a", "Edit") |> render_click() =~
               "Edit Distributor"

      assert_patch(index_live, Routes.distributor_index_path(conn, :edit, distributor))

      assert index_live
             |> form("#distributor-form", distributor: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#distributor-form", distributor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.distributor_index_path(conn, :index))

      assert html =~ "Distributor updated successfully"
      assert html =~ "some updated brand"
    end

    test "deletes distributor in listing", %{conn: conn, distributor: distributor} do
      {:ok, index_live, _html} = live(conn, Routes.distributor_index_path(conn, :index))

      assert index_live |> element("#distributor-#{distributor.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#distributor-#{distributor.id}")
    end
  end

  describe "Show" do
    setup [:create_distributor]

    test "displays distributor", %{conn: conn, distributor: distributor} do
      {:ok, _show_live, html} = live(conn, Routes.distributor_show_path(conn, :show, distributor))

      assert html =~ "Show Distributor"
      assert html =~ distributor.brand
    end

    test "updates distributor within modal", %{conn: conn, distributor: distributor} do
      {:ok, show_live, _html} = live(conn, Routes.distributor_show_path(conn, :show, distributor))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Distributor"

      assert_patch(show_live, Routes.distributor_show_path(conn, :edit, distributor))

      assert show_live
             |> form("#distributor-form", distributor: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#distributor-form", distributor: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.distributor_show_path(conn, :show, distributor))

      assert html =~ "Distributor updated successfully"
      assert html =~ "some updated brand"
    end
  end
end
