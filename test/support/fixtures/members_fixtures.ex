defmodule Basic.MembersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Members` context.
  """

  @doc """
  Generate a member.
  """
  def member_fixture(attrs \\ %{}) do
    {:ok, member} =
      attrs
      |> Enum.into(%{
        birthday: ~N[2022-01-12 01:31:00],
        deleted_at: ~N[2022-01-12 01:31:00],
        department: "some department",
        detail: "some detail",
        first_name: "some first_name",
        first_name_kana: "some first_name_kana",
        image: "some image",
        industry: "some industry",
        last_name: "some last_name",
        last_name_kana: "some last_name_kana",
        organization_id: 42,
        organization_name: "some organization_name",
        position: "some position",
        user_id: 42
      })
      |> Basic.Members.create_member()

    member
  end
end
