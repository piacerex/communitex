defmodule BasicWeb.ItemLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Basic.Items

  @create_attrs %{alls: 42, area: "some area", close_date: ~N[2010-04-17 14:00:00], deleted_at: ~N[2010-04-17 14:00:00], detail: "some detail", distributor_id: 42, end_date: ~N[2010-04-17 14:00:00], image: "some image", is_open: true, name: "some name", occupation: "some occupation", open_date: ~N[2010-04-17 14:00:00], price: 120.5, start_date: ~N[2010-04-17 14:00:00], stocks: 42}
  @update_attrs %{alls: 43, area: "some updated area", close_date: ~N[2011-05-18 15:01:01], deleted_at: ~N[2011-05-18 15:01:01], detail: "some updated detail", distributor_id: 43, end_date: ~N[2011-05-18 15:01:01], image: "some updated image", is_open: false, name: "some updated name", occupation: "some updated occupation", open_date: ~N[2011-05-18 15:01:01], price: 456.7, start_date: ~N[2011-05-18 15:01:01], stocks: 43}
  @invalid_attrs %{alls: nil, area: nil, close_date: nil, deleted_at: nil, detail: nil, distributor_id: nil, end_date: nil, image: nil, is_open: nil, name: nil, occupation: nil, open_date: nil, price: nil, start_date: nil, stocks: nil}

  defp fixture(:item) do
    {:ok, item} = Items.create_item(@create_attrs)
    item
  end

  defp create_item(_) do
    item = fixture(:item)
    %{item: item}
  end

  describe "Index" do
    setup [:create_item]

    test "lists all items", %{conn: conn, item: item} do
      {:ok, _index_live, html} = live(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Listing Items"
      assert html =~ item.area
    end

    test "saves new item", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("a", "New Item") |> render_click() =~
               "New Item"

      assert_patch(index_live, Routes.item_index_path(conn, :new))

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Item created successfully"
      assert html =~ "some area"
    end

    test "updates item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(index_live, Routes.item_index_path(conn, :edit, item))

      assert index_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#item-form", item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_index_path(conn, :index))

      assert html =~ "Item updated successfully"
      assert html =~ "some updated area"
    end

    test "deletes item in listing", %{conn: conn, item: item} do
      {:ok, index_live, _html} = live(conn, Routes.item_index_path(conn, :index))

      assert index_live |> element("#item-#{item.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#item-#{item.id}")
    end
  end

  describe "Show" do
    setup [:create_item]

    test "displays item", %{conn: conn, item: item} do
      {:ok, _show_live, html} = live(conn, Routes.item_show_path(conn, :show, item))

      assert html =~ "Show Item"
      assert html =~ item.area
    end

    test "updates item within modal", %{conn: conn, item: item} do
      {:ok, show_live, _html} = live(conn, Routes.item_show_path(conn, :show, item))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Item"

      assert_patch(show_live, Routes.item_show_path(conn, :edit, item))

      assert show_live
             |> form("#item-form", item: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#item-form", item: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.item_show_path(conn, :show, item))

      assert html =~ "Item updated successfully"
      assert html =~ "some updated area"
    end
  end
end
