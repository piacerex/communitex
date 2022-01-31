defmodule Basic.OrganizationsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Organizations` context.
  """

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        address1: "some address1",
        address2: "some address2",
        city: "some city",
        deleted_at: ~N[2022-01-12 01:45:00],
        name: "some name",
        postal: "some postal",
        prefecture: "some prefecture",
        tel: "some tel"
      })
      |> Basic.Organizations.create_organization()

    organization
  end
end
