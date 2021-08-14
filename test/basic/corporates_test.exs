defmodule Basic.CorporatesTest do
  use Basic.DataCase

  alias Basic.Corporates

  describe "corporates" do
    alias Basic.Corporates.Corporate

    @valid_attrs %{address1: "some address1", address2: "some address2", city: "some city", deleted_at: ~N[2010-04-17 14:00:00], name: "some name", postal: "some postal", prefecture: "some prefecture", tel: "some tel"}
    @update_attrs %{address1: "some updated address1", address2: "some updated address2", city: "some updated city", deleted_at: ~N[2011-05-18 15:01:01], name: "some updated name", postal: "some updated postal", prefecture: "some updated prefecture", tel: "some updated tel"}
    @invalid_attrs %{address1: nil, address2: nil, city: nil, deleted_at: nil, name: nil, postal: nil, prefecture: nil, tel: nil}

    def corporate_fixture(attrs \\ %{}) do
      {:ok, corporate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Corporates.create_corporate()

      corporate
    end

    test "list_corporates/0 returns all corporates" do
      corporate = corporate_fixture()
      assert Corporates.list_corporates() == [corporate]
    end

    test "get_corporate!/1 returns the corporate with given id" do
      corporate = corporate_fixture()
      assert Corporates.get_corporate!(corporate.id) == corporate
    end

    test "create_corporate/1 with valid data creates a corporate" do
      assert {:ok, %Corporate{} = corporate} = Corporates.create_corporate(@valid_attrs)
      assert corporate.address1 == "some address1"
      assert corporate.address2 == "some address2"
      assert corporate.city == "some city"
      assert corporate.deleted_at == ~N[2010-04-17 14:00:00]
      assert corporate.name == "some name"
      assert corporate.postal == "some postal"
      assert corporate.prefecture == "some prefecture"
      assert corporate.tel == "some tel"
    end

    test "create_corporate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Corporates.create_corporate(@invalid_attrs)
    end

    test "update_corporate/2 with valid data updates the corporate" do
      corporate = corporate_fixture()
      assert {:ok, %Corporate{} = corporate} = Corporates.update_corporate(corporate, @update_attrs)
      assert corporate.address1 == "some updated address1"
      assert corporate.address2 == "some updated address2"
      assert corporate.city == "some updated city"
      assert corporate.deleted_at == ~N[2011-05-18 15:01:01]
      assert corporate.name == "some updated name"
      assert corporate.postal == "some updated postal"
      assert corporate.prefecture == "some updated prefecture"
      assert corporate.tel == "some updated tel"
    end

    test "update_corporate/2 with invalid data returns error changeset" do
      corporate = corporate_fixture()
      assert {:error, %Ecto.Changeset{}} = Corporates.update_corporate(corporate, @invalid_attrs)
      assert corporate == Corporates.get_corporate!(corporate.id)
    end

    test "delete_corporate/1 deletes the corporate" do
      corporate = corporate_fixture()
      assert {:ok, %Corporate{}} = Corporates.delete_corporate(corporate)
      assert_raise Ecto.NoResultsError, fn -> Corporates.get_corporate!(corporate.id) end
    end

    test "change_corporate/1 returns a corporate changeset" do
      corporate = corporate_fixture()
      assert %Ecto.Changeset{} = Corporates.change_corporate(corporate)
    end
  end
end
