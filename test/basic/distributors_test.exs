defmodule Basic.DistributorsTest do
  use Basic.DataCase

  alias Basic.Distributors

  describe "distributors" do
    alias Basic.Distributors.Distributor

    import Basic.DistributorsFixtures

    @invalid_attrs %{brand: nil, deleted_at: nil, organization_id: nil}

    test "list_distributors/0 returns all distributors" do
      distributor = distributor_fixture()
      assert Distributors.list_distributors() == [distributor]
    end

    test "get_distributor!/1 returns the distributor with given id" do
      distributor = distributor_fixture()
      assert Distributors.get_distributor!(distributor.id) == distributor
    end

    test "create_distributor/1 with valid data creates a distributor" do
      valid_attrs = %{brand: "some brand", deleted_at: ~N[2022-01-12 01:49:00], organization_id: 42}

      assert {:ok, %Distributor{} = distributor} = Distributors.create_distributor(valid_attrs)
      assert distributor.brand == "some brand"
      assert distributor.deleted_at == ~N[2022-01-12 01:49:00]
      assert distributor.organization_id == 42
    end

    test "create_distributor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Distributors.create_distributor(@invalid_attrs)
    end

    test "update_distributor/2 with valid data updates the distributor" do
      distributor = distributor_fixture()
      update_attrs = %{brand: "some updated brand", deleted_at: ~N[2022-01-13 01:49:00], organization_id: 43}

      assert {:ok, %Distributor{} = distributor} = Distributors.update_distributor(distributor, update_attrs)
      assert distributor.brand == "some updated brand"
      assert distributor.deleted_at == ~N[2022-01-13 01:49:00]
      assert distributor.organization_id == 43
    end

    test "update_distributor/2 with invalid data returns error changeset" do
      distributor = distributor_fixture()
      assert {:error, %Ecto.Changeset{}} = Distributors.update_distributor(distributor, @invalid_attrs)
      assert distributor == Distributors.get_distributor!(distributor.id)
    end

    test "delete_distributor/1 deletes the distributor" do
      distributor = distributor_fixture()
      assert {:ok, %Distributor{}} = Distributors.delete_distributor(distributor)
      assert_raise Ecto.NoResultsError, fn -> Distributors.get_distributor!(distributor.id) end
    end

    test "change_distributor/1 returns a distributor changeset" do
      distributor = distributor_fixture()
      assert %Ecto.Changeset{} = Distributors.change_distributor(distributor)
    end
  end
end
