defmodule Basic.DeliveriesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Deliveries` context.
  """

  @doc """
  Generate a delivery.
  """
  def delivery_fixture(attrs \\ %{}) do
    {:ok, delivery} =
      attrs
      |> Enum.into(%{
        address_id: 42,
        order_id: 42,
        order_number: "some order_number",
        phase: "some phase"
      })
      |> Basic.Deliveries.create_delivery()

    delivery
  end
end
