defmodule Basic.AddressesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Addresses` context.
  """

  @doc """
  Generate a address.
  """
  def address_fixture(attrs \\ %{}) do
    {:ok, address} =
      attrs
      |> Enum.into(%{
        address1: "some address1",
        address2: "some address2",
        city: "some city",
        first_name: "some first_name",
        last_name: "some last_name",
        postal: "some postal",
        prefecture: "some prefecture",
        tel: "some tel",
        user_id: 42
      })
      |> Basic.Addresses.create_address()

    address
  end
end
