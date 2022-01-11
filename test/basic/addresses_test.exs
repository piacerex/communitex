defmodule Basic.AddressesTest do
  use Basic.DataCase

  alias Basic.Addresses

  describe "addresses" do
    alias Basic.Addresses.Address

    @valid_attrs %{address1: "some address1", address2: "some address2", city: "some city", first_name: "some first_name", last_name: "some last_name", postal: "some postal", prefecture: "some prefecture", tel: "some tel", user_id: 42}
    @update_attrs %{address1: "some updated address1", address2: "some updated address2", city: "some updated city", first_name: "some updated first_name", last_name: "some updated last_name", postal: "some updated postal", prefecture: "some updated prefecture", tel: "some updated tel", user_id: 43}
    @invalid_attrs %{address1: nil, address2: nil, city: nil, first_name: nil, last_name: nil, postal: nil, prefecture: nil, tel: nil, user_id: nil}

    def address_fixture(attrs \\ %{}) do
      {:ok, address} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Addresses.create_address()

      address
    end

    test "list_addresses/0 returns all addresses" do
      address = address_fixture()
      assert Addresses.list_addresses() == [address]
    end

    test "get_address!/1 returns the address with given id" do
      address = address_fixture()
      assert Addresses.get_address!(address.id) == address
    end

    test "create_address/1 with valid data creates a address" do
      assert {:ok, %Address{} = address} = Addresses.create_address(@valid_attrs)
      assert address.address1 == "some address1"
      assert address.address2 == "some address2"
      assert address.city == "some city"
      assert address.first_name == "some first_name"
      assert address.last_name == "some last_name"
      assert address.postal == "some postal"
      assert address.prefecture == "some prefecture"
      assert address.tel == "some tel"
      assert address.user_id == 42
    end

    test "create_address/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Addresses.create_address(@invalid_attrs)
    end

    test "update_address/2 with valid data updates the address" do
      address = address_fixture()
      assert {:ok, %Address{} = address} = Addresses.update_address(address, @update_attrs)
      assert address.address1 == "some updated address1"
      assert address.address2 == "some updated address2"
      assert address.city == "some updated city"
      assert address.first_name == "some updated first_name"
      assert address.last_name == "some updated last_name"
      assert address.postal == "some updated postal"
      assert address.prefecture == "some updated prefecture"
      assert address.tel == "some updated tel"
      assert address.user_id == 43
    end

    test "update_address/2 with invalid data returns error changeset" do
      address = address_fixture()
      assert {:error, %Ecto.Changeset{}} = Addresses.update_address(address, @invalid_attrs)
      assert address == Addresses.get_address!(address.id)
    end

    test "delete_address/1 deletes the address" do
      address = address_fixture()
      assert {:ok, %Address{}} = Addresses.delete_address(address)
      assert_raise Ecto.NoResultsError, fn -> Addresses.get_address!(address.id) end
    end

    test "change_address/1 returns a address changeset" do
      address = address_fixture()
      assert %Ecto.Changeset{} = Addresses.change_address(address)
    end
  end
end
