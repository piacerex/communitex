defmodule Basic.CartsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Carts` context.
  """

  @doc """
  Generate a cart.
  """
  def cart_fixture(attrs \\ %{}) do
    {:ok, cart} =
      attrs
      |> Enum.into(%{
        is_order: true,
        item_id: 42,
        quantity: 42,
        user_id: 42
      })
      |> Basic.Carts.create_cart()

    cart
  end
end
