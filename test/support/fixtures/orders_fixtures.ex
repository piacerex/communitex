defmodule Basic.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        canceled_at: ~N[2022-01-12 01:52:00],
        deleted_at: ~N[2022-01-12 01:52:00],
        discount: 120.5,
        is_cancel: true,
        item_id: 42,
        order_date: ~N[2022-01-12 01:52:00],
        order_number: "some order_number",
        price: 120.5,
        user_id: 42
      })
      |> Basic.Orders.create_order()

    order
  end
end
