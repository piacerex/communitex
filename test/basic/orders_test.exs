defmodule Basic.OrdersTest do
  use Basic.DataCase

  alias Basic.Orders

  describe "orders" do
    alias Basic.Orders.Order

    import Basic.OrdersFixtures

    @invalid_attrs %{canceled_at: nil, deleted_at: nil, discount: nil, is_cancel: nil, item_id: nil, order_date: nil, order_number: nil, price: nil, user_id: nil}

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{canceled_at: ~N[2022-01-12 01:52:00], deleted_at: ~N[2022-01-12 01:52:00], discount: 120.5, is_cancel: true, item_id: 42, order_date: ~N[2022-01-12 01:52:00], order_number: "some order_number", price: 120.5, user_id: 42}

      assert {:ok, %Order{} = order} = Orders.create_order(valid_attrs)
      assert order.canceled_at == ~N[2022-01-12 01:52:00]
      assert order.deleted_at == ~N[2022-01-12 01:52:00]
      assert order.discount == 120.5
      assert order.is_cancel == true
      assert order.item_id == 42
      assert order.order_date == ~N[2022-01-12 01:52:00]
      assert order.order_number == "some order_number"
      assert order.price == 120.5
      assert order.user_id == 42
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      update_attrs = %{canceled_at: ~N[2022-01-13 01:52:00], deleted_at: ~N[2022-01-13 01:52:00], discount: 456.7, is_cancel: false, item_id: 43, order_date: ~N[2022-01-13 01:52:00], order_number: "some updated order_number", price: 456.7, user_id: 43}

      assert {:ok, %Order{} = order} = Orders.update_order(order, update_attrs)
      assert order.canceled_at == ~N[2022-01-13 01:52:00]
      assert order.deleted_at == ~N[2022-01-13 01:52:00]
      assert order.discount == 456.7
      assert order.is_cancel == false
      assert order.item_id == 43
      assert order.order_date == ~N[2022-01-13 01:52:00]
      assert order.order_number == "some updated order_number"
      assert order.price == 456.7
      assert order.user_id == 43
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_order(order, @invalid_attrs)
      assert order == Orders.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Orders.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Orders.change_order(order)
    end
  end
end
