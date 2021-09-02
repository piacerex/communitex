defmodule Basic.OrganizationsTest do
  use Basic.DataCase

  alias Basic.Organizations

  describe "organizations" do
    alias Basic.Organizations.Organization

    @valid_attrs %{address1: "some address1", address2: "some address2", city: "some city", deleted_at: ~N[2010-04-17 14:00:00], name: "some name", postal: "some postal", prefecture: "some prefecture", tel: "some tel"}
    @update_attrs %{address1: "some updated address1", address2: "some updated address2", city: "some updated city", deleted_at: ~N[2011-05-18 15:01:01], name: "some updated name", postal: "some updated postal", prefecture: "some updated prefecture", tel: "some updated tel"}
    @invalid_attrs %{address1: nil, address2: nil, city: nil, deleted_at: nil, name: nil, postal: nil, prefecture: nil, tel: nil}

    def organization_fixture(attrs \\ %{}) do
      {:ok, organization} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Organizations.create_organization()

      organization
    end

    test "list_organizations/0 returns all organizations" do
      organization = organization_fixture()
      assert Organizations.list_organizations() == [organization]
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Organizations.get_organization!(organization.id) == organization
    end

    test "create_organization/1 with valid data creates a organization" do
      assert {:ok, %Organization{} = organization} = Organizations.create_organization(@valid_attrs)
      assert organization.address1 == "some address1"
      assert organization.address2 == "some address2"
      assert organization.city == "some city"
      assert organization.deleted_at == ~N[2010-04-17 14:00:00]
      assert organization.name == "some name"
      assert organization.postal == "some postal"
      assert organization.prefecture == "some prefecture"
      assert organization.tel == "some tel"
    end

    test "create_organization/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(@invalid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{} = organization} = Organizations.update_organization(organization, @update_attrs)
      assert organization.address1 == "some updated address1"
      assert organization.address2 == "some updated address2"
      assert organization.city == "some updated city"
      assert organization.deleted_at == ~N[2011-05-18 15:01:01]
      assert organization.name == "some updated name"
      assert organization.postal == "some updated postal"
      assert organization.prefecture == "some updated prefecture"
      assert organization.tel == "some updated tel"
    end

    test "update_organization/2 with invalid data returns error changeset" do
      organization = organization_fixture()
      assert {:error, %Ecto.Changeset{}} = Organizations.update_organization(organization, @invalid_attrs)
      assert organization == Organizations.get_organization!(organization.id)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end
  end
end
