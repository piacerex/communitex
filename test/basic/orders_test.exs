defmodule Basic.OrdersTest do
  use Basic.DataCase

  alias Basic.Orders

  describe "orders" do
    alias Basic.Orders.Order

    @valid_attrs %{deleted_at: ~N[2010-04-17 14:00:00], discount: 120.5, is_cancel: true, item_id: 42, order_date: ~D[2010-04-17], price: 120.5, user_id: 42}
    @update_attrs %{deleted_at: ~N[2011-05-18 15:01:01], discount: 456.7, is_cancel: false, item_id: 43, order_date: ~D[2011-05-18], price: 456.7, user_id: 43}
    @invalid_attrs %{deleted_at: nil, discount: nil, is_cancel: nil, item_id: nil, order_date: nil, price: nil, user_id: nil}

    def order_fixture(attrs \\ %{}) do
      {:ok, order} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Orders.create_order()

      order
    end

    test "list_orders/0 returns all orders" do
      order = order_fixture()
      assert Orders.list_orders() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Orders.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      assert {:ok, %Order{} = order} = Orders.create_order(@valid_attrs)
      assert order.deleted_at == ~N[2010-04-17 14:00:00]
      assert order.discount == 120.5
      assert order.is_cancel == true
      assert order.item_id == 42
      assert order.order_date == ~D[2010-04-17]
      assert order.price == 120.5
      assert order.user_id == 42
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      assert {:ok, %Order{} = order} = Orders.update_order(order, @update_attrs)
      assert order.deleted_at == ~N[2011-05-18 15:01:01]
      assert order.discount == 456.7
      assert order.is_cancel == false
      assert order.item_id == 43
      assert order.order_date == ~D[2011-05-18]
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
