defmodule Basic.DistributorsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Distributors` context.
  """

  @doc """
  Generate a distributor.
  """
  def distributor_fixture(attrs \\ %{}) do
    {:ok, distributor} =
      attrs
      |> Enum.into(%{
        brand: "some brand",
        deleted_at: ~N[2022-01-12 01:49:00],
        organization_id: 42
      })
      |> Basic.Distributors.create_distributor()

    distributor
  end
end
