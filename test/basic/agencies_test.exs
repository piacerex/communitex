defmodule Basic.AgenciesTest do
  use Basic.DataCase

  alias Basic.Agencies

  describe "agencies" do
    alias Basic.Agencies.Agency

    @valid_attrs %{boost: 120.5, brand: "some brand", organization_id: 42, deleted_at: ~N[2010-04-17 14:00:00], discount: 120.5, distributor_id: 42}
    @update_attrs %{boost: 456.7, brand: "some updated brand", organization_id: 43, deleted_at: ~N[2011-05-18 15:01:01], discount: 456.7, distributor_id: 43}
    @invalid_attrs %{boost: nil, brand: nil, organization_id: nil, deleted_at: nil, discount: nil, distributor_id: nil}

    def agency_fixture(attrs \\ %{}) do
      {:ok, agency} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Agencies.create_agency()

      agency
    end

    test "list_agencies/0 returns all agencies" do
      agency = agency_fixture()
      assert Agencies.list_agencies() == [agency]
    end

    test "get_agency!/1 returns the agency with given id" do
      agency = agency_fixture()
      assert Agencies.get_agency!(agency.id) == agency
    end

    test "create_agency/1 with valid data creates a agency" do
      assert {:ok, %Agency{} = agency} = Agencies.create_agency(@valid_attrs)
      assert agency.boost == 120.5
      assert agency.brand == "some brand"
      assert agency.organization_id == 42
      assert agency.deleted_at == ~N[2010-04-17 14:00:00]
      assert agency.discount == 120.5
      assert agency.distributor_id == 42
    end

    test "create_agency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agencies.create_agency(@invalid_attrs)
    end

    test "update_agency/2 with valid data updates the agency" do
      agency = agency_fixture()
      assert {:ok, %Agency{} = agency} = Agencies.update_agency(agency, @update_attrs)
      assert agency.boost == 456.7
      assert agency.brand == "some updated brand"
      assert agency.organization_id == 43
      assert agency.deleted_at == ~N[2011-05-18 15:01:01]
      assert agency.discount == 456.7
      assert agency.distributor_id == 43
    end

    test "update_agency/2 with invalid data returns error changeset" do
      agency = agency_fixture()
      assert {:error, %Ecto.Changeset{}} = Agencies.update_agency(agency, @invalid_attrs)
      assert agency == Agencies.get_agency!(agency.id)
    end

    test "delete_agency/1 deletes the agency" do
      agency = agency_fixture()
      assert {:ok, %Agency{}} = Agencies.delete_agency(agency)
      assert_raise Ecto.NoResultsError, fn -> Agencies.get_agency!(agency.id) end
    end

    test "change_agency/1 returns a agency changeset" do
      agency = agency_fixture()
      assert %Ecto.Changeset{} = Agencies.change_agency(agency)
    end
  end

  describe "agencies" do
    alias Basic.Agencies.Agency

    @valid_attrs %{boost: 120.5, brand: "some brand", deleted_at: ~N[2010-04-17 14:00:00], discount: 120.5, distributor_id: 42, organization_id: 42}
    @update_attrs %{boost: 456.7, brand: "some updated brand", deleted_at: ~N[2011-05-18 15:01:01], discount: 456.7, distributor_id: 43, organization_id: 43}
    @invalid_attrs %{boost: nil, brand: nil, deleted_at: nil, discount: nil, distributor_id: nil, organization_id: nil}

    def agency_fixture(attrs \\ %{}) do
      {:ok, agency} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Agencies.create_agency()

      agency
    end

    test "list_agencies/0 returns all agencies" do
      agency = agency_fixture()
      assert Agencies.list_agencies() == [agency]
    end

    test "get_agency!/1 returns the agency with given id" do
      agency = agency_fixture()
      assert Agencies.get_agency!(agency.id) == agency
    end

    test "create_agency/1 with valid data creates a agency" do
      assert {:ok, %Agency{} = agency} = Agencies.create_agency(@valid_attrs)
      assert agency.boost == 120.5
      assert agency.brand == "some brand"
      assert agency.deleted_at == ~N[2010-04-17 14:00:00]
      assert agency.discount == 120.5
      assert agency.distributor_id == 42
      assert agency.organization_id == 42
    end

    test "create_agency/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agencies.create_agency(@invalid_attrs)
    end

    test "update_agency/2 with valid data updates the agency" do
      agency = agency_fixture()
      assert {:ok, %Agency{} = agency} = Agencies.update_agency(agency, @update_attrs)
      assert agency.boost == 456.7
      assert agency.brand == "some updated brand"
      assert agency.deleted_at == ~N[2011-05-18 15:01:01]
      assert agency.discount == 456.7
      assert agency.distributor_id == 43
      assert agency.organization_id == 43
    end

    test "update_agency/2 with invalid data returns error changeset" do
      agency = agency_fixture()
      assert {:error, %Ecto.Changeset{}} = Agencies.update_agency(agency, @invalid_attrs)
      assert agency == Agencies.get_agency!(agency.id)
    end

    test "delete_agency/1 deletes the agency" do
      agency = agency_fixture()
      assert {:ok, %Agency{}} = Agencies.delete_agency(agency)
      assert_raise Ecto.NoResultsError, fn -> Agencies.get_agency!(agency.id) end
    end

    test "change_agency/1 returns a agency changeset" do
      agency = agency_fixture()
      assert %Ecto.Changeset{} = Agencies.change_agency(agency)
    end
  end
end
