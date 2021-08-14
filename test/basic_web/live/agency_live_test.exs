defmodule BasicWeb.AgencyLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Basic.Agencies

  @create_attrs %{boost: 120.5, brand: "some brand", corporate_id: 42, deleted_at: ~N[2010-04-17 14:00:00], discount: 120.5, distributor_id: 42}
  @update_attrs %{boost: 456.7, brand: "some updated brand", corporate_id: 43, deleted_at: ~N[2011-05-18 15:01:01], discount: 456.7, distributor_id: 43}
  @invalid_attrs %{boost: nil, brand: nil, corporate_id: nil, deleted_at: nil, discount: nil, distributor_id: nil}

  defp fixture(:agency) do
    {:ok, agency} = Agencies.create_agency(@create_attrs)
    agency
  end

  defp create_agency(_) do
    agency = fixture(:agency)
    %{agency: agency}
  end

  describe "Index" do
    setup [:create_agency]

    test "lists all agencies", %{conn: conn, agency: agency} do
      {:ok, _index_live, html} = live(conn, Routes.agency_index_path(conn, :index))

      assert html =~ "Listing Agencies"
      assert html =~ agency.brand
    end

    test "saves new agency", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.agency_index_path(conn, :index))

      assert index_live |> element("a", "New Agency") |> render_click() =~
               "New Agency"

      assert_patch(index_live, Routes.agency_index_path(conn, :new))

      assert index_live
             |> form("#agency-form", agency: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#agency-form", agency: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.agency_index_path(conn, :index))

      assert html =~ "Agency created successfully"
      assert html =~ "some brand"
    end

    test "updates agency in listing", %{conn: conn, agency: agency} do
      {:ok, index_live, _html} = live(conn, Routes.agency_index_path(conn, :index))

      assert index_live |> element("#agency-#{agency.id} a", "Edit") |> render_click() =~
               "Edit Agency"

      assert_patch(index_live, Routes.agency_index_path(conn, :edit, agency))

      assert index_live
             |> form("#agency-form", agency: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#agency-form", agency: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.agency_index_path(conn, :index))

      assert html =~ "Agency updated successfully"
      assert html =~ "some updated brand"
    end

    test "deletes agency in listing", %{conn: conn, agency: agency} do
      {:ok, index_live, _html} = live(conn, Routes.agency_index_path(conn, :index))

      assert index_live |> element("#agency-#{agency.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#agency-#{agency.id}")
    end
  end

  describe "Show" do
    setup [:create_agency]

    test "displays agency", %{conn: conn, agency: agency} do
      {:ok, _show_live, html} = live(conn, Routes.agency_show_path(conn, :show, agency))

      assert html =~ "Show Agency"
      assert html =~ agency.brand
    end

    test "updates agency within modal", %{conn: conn, agency: agency} do
      {:ok, show_live, _html} = live(conn, Routes.agency_show_path(conn, :show, agency))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Agency"

      assert_patch(show_live, Routes.agency_show_path(conn, :edit, agency))

      assert show_live
             |> form("#agency-form", agency: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#agency-form", agency: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.agency_show_path(conn, :show, agency))

      assert html =~ "Agency updated successfully"
      assert html =~ "some updated brand"
    end
  end
end
