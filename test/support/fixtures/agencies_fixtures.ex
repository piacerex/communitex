defmodule Basic.AgenciesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Agencies` context.
  """

  @doc """
  Generate a agency.
  """
  def agency_fixture(attrs \\ %{}) do
    {:ok, agency} =
      attrs
      |> Enum.into(%{
        boost: 120.5,
        brand: "some brand",
        deleted_at: ~N[2022-01-12 01:50:00],
        discount: 120.5,
        distributor_id: 42,
        organization_id: 42
      })
      |> Basic.Agencies.create_agency()

    agency
  end
end
