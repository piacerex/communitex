defmodule Basic.CartsTest do
  use Basic.DataCase

  alias Basic.Carts

  describe "carts" do
    alias Basic.Carts.Cart

    import Basic.CartsFixtures

    @invalid_attrs %{is_order: nil, item_id: nil, quantity: nil, user_id: nil}

    test "list_carts/0 returns all carts" do
      cart = cart_fixture()
      assert Carts.list_carts() == [cart]
    end

    test "get_cart!/1 returns the cart with given id" do
      cart = cart_fixture()
      assert Carts.get_cart!(cart.id) == cart
    end

    test "create_cart/1 with valid data creates a cart" do
      valid_attrs = %{is_order: true, item_id: 42, quantity: 42, user_id: 42}

      assert {:ok, %Cart{} = cart} = Carts.create_cart(valid_attrs)
      assert cart.is_order == true
      assert cart.item_id == 42
      assert cart.quantity == 42
      assert cart.user_id == 42
    end

    test "create_cart/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Carts.create_cart(@invalid_attrs)
    end

    test "update_cart/2 with valid data updates the cart" do
      cart = cart_fixture()
      update_attrs = %{is_order: false, item_id: 43, quantity: 43, user_id: 43}

      assert {:ok, %Cart{} = cart} = Carts.update_cart(cart, update_attrs)
      assert cart.is_order == false
      assert cart.item_id == 43
      assert cart.quantity == 43
      assert cart.user_id == 43
    end

    test "update_cart/2 with invalid data returns error changeset" do
      cart = cart_fixture()
      assert {:error, %Ecto.Changeset{}} = Carts.update_cart(cart, @invalid_attrs)
      assert cart == Carts.get_cart!(cart.id)
    end

    test "delete_cart/1 deletes the cart" do
      cart = cart_fixture()
      assert {:ok, %Cart{}} = Carts.delete_cart(cart)
      assert_raise Ecto.NoResultsError, fn -> Carts.get_cart!(cart.id) end
    end

    test "change_cart/1 returns a cart changeset" do
      cart = cart_fixture()
      assert %Ecto.Changeset{} = Carts.change_cart(cart)
    end
  end
end
