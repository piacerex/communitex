defmodule Basic.ItemsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Items` context.
  """

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        alls: 42,
        area: "some area",
        close_date: ~N[2022-01-12 01:46:00],
        deleted_at: ~N[2022-01-12 01:46:00],
        delivery_require: true,
        detail: "some detail",
        distributor_id: 42,
        end_date: ~N[2022-01-12 01:46:00],
        image: "some image",
        is_open: true,
        name: "some name",
        occupation: "some occupation",
        open_date: ~N[2022-01-12 01:46:00],
        payment_cycle: "some payment_cycle",
        price: 120.5,
        start_date: ~N[2022-01-12 01:46:00],
        stocks: 42
      })
      |> Basic.Items.create_item()

    item
  end
end
