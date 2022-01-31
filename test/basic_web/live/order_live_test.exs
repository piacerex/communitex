defmodule BasicWeb.OrderLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Basic.OrdersFixtures

  @create_attrs %{canceled_at: %{day: 12, hour: 1, minute: 52, month: 1, year: 2022}, deleted_at: %{day: 12, hour: 1, minute: 52, month: 1, year: 2022}, discount: 120.5, is_cancel: true, item_id: 42, order_date: %{day: 12, hour: 1, minute: 52, month: 1, year: 2022}, order_number: "some order_number", price: 120.5, user_id: 42}
  @update_attrs %{canceled_at: %{day: 13, hour: 1, minute: 52, month: 1, year: 2022}, deleted_at: %{day: 13, hour: 1, minute: 52, month: 1, year: 2022}, discount: 456.7, is_cancel: false, item_id: 43, order_date: %{day: 13, hour: 1, minute: 52, month: 1, year: 2022}, order_number: "some updated order_number", price: 456.7, user_id: 43}
  @invalid_attrs %{canceled_at: %{day: 30, hour: 1, minute: 52, month: 2, year: 2022}, deleted_at: %{day: 30, hour: 1, minute: 52, month: 2, year: 2022}, discount: nil, is_cancel: false, item_id: nil, order_date: %{day: 30, hour: 1, minute: 52, month: 2, year: 2022}, order_number: nil, price: nil, user_id: nil}

  defp create_order(_) do
    order = order_fixture()
    %{order: order}
  end

  describe "Index" do
    setup [:create_order]

    test "lists all orders", %{conn: conn, order: order} do
      {:ok, _index_live, html} = live(conn, Routes.order_index_path(conn, :index))

      assert html =~ "Listing Orders"
      assert html =~ order.order_number
    end

    test "saves new order", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.order_index_path(conn, :index))

      assert index_live |> element("a", "New Order") |> render_click() =~
               "New Order"

      assert_patch(index_live, Routes.order_index_path(conn, :new))

      assert index_live
             |> form("#order-form", order: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#order-form", order: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.order_index_path(conn, :index))

      assert html =~ "Order created successfully"
      assert html =~ "some order_number"
    end

    test "updates order in listing", %{conn: conn, order: order} do
      {:ok, index_live, _html} = live(conn, Routes.order_index_path(conn, :index))

      assert index_live |> element("#order-#{order.id} a", "Edit") |> render_click() =~
               "Edit Order"

      assert_patch(index_live, Routes.order_index_path(conn, :edit, order))

      assert index_live
             |> form("#order-form", order: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#order-form", order: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.order_index_path(conn, :index))

      assert html =~ "Order updated successfully"
      assert html =~ "some updated order_number"
    end

    test "deletes order in listing", %{conn: conn, order: order} do
      {:ok, index_live, _html} = live(conn, Routes.order_index_path(conn, :index))

      assert index_live |> element("#order-#{order.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#order-#{order.id}")
    end
  end

  describe "Show" do
    setup [:create_order]

    test "displays order", %{conn: conn, order: order} do
      {:ok, _show_live, html} = live(conn, Routes.order_show_path(conn, :show, order))

      assert html =~ "Show Order"
      assert html =~ order.order_number
    end

    test "updates order within modal", %{conn: conn, order: order} do
      {:ok, show_live, _html} = live(conn, Routes.order_show_path(conn, :show, order))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Order"

      assert_patch(show_live, Routes.order_show_path(conn, :edit, order))

      assert show_live
             |> form("#order-form", order: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#order-form", order: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.order_show_path(conn, :show, order))

      assert html =~ "Order updated successfully"
      assert html =~ "some updated order_number"
    end
  end
end
