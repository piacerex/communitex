defmodule Basic.GrantsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Grants` context.
  """

  @doc """
  Generate a grant.
  """
  def grant_fixture(attrs \\ %{}) do
    {:ok, grant} =
      attrs
      |> Enum.into(%{
        deleted_at: ~N[2022-01-12 01:45:00],
        organization_id: 42,
        role: "some role",
        user_id: 42
      })
      |> Basic.Grants.create_grant()

    grant
  end
end
