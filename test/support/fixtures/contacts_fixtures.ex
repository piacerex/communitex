defmodule Basic.ContactsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Contacts` context.
  """

  @doc """
  Generate a contact.
  """
  def contact_fixture(attrs \\ %{}) do
    {:ok, contact} =
      attrs
      |> Enum.into(%{
        body: "some body",
        deleted_at: ~N[2022-01-12 01:52:00],
        email: "some email",
        first_name: "some first_name",
        first_name_kana: "some first_name_kana",
        last_name: "some last_name",
        last_name_kana: "some last_name_kana",
        logined_user_id: 42,
        type: "some type"
      })
      |> Basic.Contacts.create_contact()

    contact
  end
end
