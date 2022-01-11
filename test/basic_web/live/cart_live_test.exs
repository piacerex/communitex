defmodule BasicWeb.CartLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Basic.Carts

  @create_attrs %{is_order: true, item_id: 42, quantity: 42, user_id: 42}
  @update_attrs %{is_order: false, item_id: 43, quantity: 43, user_id: 43}
  @invalid_attrs %{is_order: nil, item_id: nil, quantity: nil, user_id: nil}

  defp fixture(:cart) do
    {:ok, cart} = Carts.create_cart(@create_attrs)
    cart
  end

  defp create_cart(_) do
    cart = fixture(:cart)
    %{cart: cart}
  end

  describe "Index" do
    setup [:create_cart]

    test "lists all carts", %{conn: conn, cart: cart} do
      {:ok, _index_live, html} = live(conn, Routes.cart_index_path(conn, :index))

      assert html =~ "Listing Carts"
    end

    test "saves new cart", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.cart_index_path(conn, :index))

      assert index_live |> element("a", "New Cart") |> render_click() =~
               "New Cart"

      assert_patch(index_live, Routes.cart_index_path(conn, :new))

      assert index_live
             |> form("#cart-form", cart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#cart-form", cart: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.cart_index_path(conn, :index))

      assert html =~ "Cart created successfully"
    end

    test "updates cart in listing", %{conn: conn, cart: cart} do
      {:ok, index_live, _html} = live(conn, Routes.cart_index_path(conn, :index))

      assert index_live |> element("#cart-#{cart.id} a", "Edit") |> render_click() =~
               "Edit Cart"

      assert_patch(index_live, Routes.cart_index_path(conn, :edit, cart))

      assert index_live
             |> form("#cart-form", cart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#cart-form", cart: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.cart_index_path(conn, :index))

      assert html =~ "Cart updated successfully"
    end

    test "deletes cart in listing", %{conn: conn, cart: cart} do
      {:ok, index_live, _html} = live(conn, Routes.cart_index_path(conn, :index))

      assert index_live |> element("#cart-#{cart.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#cart-#{cart.id}")
    end
  end

  describe "Show" do
    setup [:create_cart]

    test "displays cart", %{conn: conn, cart: cart} do
      {:ok, _show_live, html} = live(conn, Routes.cart_show_path(conn, :show, cart))

      assert html =~ "Show Cart"
    end

    test "updates cart within modal", %{conn: conn, cart: cart} do
      {:ok, show_live, _html} = live(conn, Routes.cart_show_path(conn, :show, cart))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Cart"

      assert_patch(show_live, Routes.cart_show_path(conn, :edit, cart))

      assert show_live
             |> form("#cart-form", cart: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#cart-form", cart: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.cart_show_path(conn, :show, cart))

      assert html =~ "Cart updated successfully"
    end
  end
end
