defmodule Basic.GrantsTest do
  use Basic.DataCase

  alias Basic.Grants

  describe "grants" do
    alias Basic.Grants.Grant

    import Basic.GrantsFixtures

    @invalid_attrs %{deleted_at: nil, organization_id: nil, role: nil, user_id: nil}

    test "list_grants/0 returns all grants" do
      grant = grant_fixture()
      assert Grants.list_grants() == [grant]
    end

    test "get_grant!/1 returns the grant with given id" do
      grant = grant_fixture()
      assert Grants.get_grant!(grant.id) == grant
    end

    test "create_grant/1 with valid data creates a grant" do
      valid_attrs = %{deleted_at: ~N[2022-01-12 01:45:00], organization_id: 42, role: "some role", user_id: 42}

      assert {:ok, %Grant{} = grant} = Grants.create_grant(valid_attrs)
      assert grant.deleted_at == ~N[2022-01-12 01:45:00]
      assert grant.organization_id == 42
      assert grant.role == "some role"
      assert grant.user_id == 42
    end

    test "create_grant/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Grants.create_grant(@invalid_attrs)
    end

    test "update_grant/2 with valid data updates the grant" do
      grant = grant_fixture()
      update_attrs = %{deleted_at: ~N[2022-01-13 01:45:00], organization_id: 43, role: "some updated role", user_id: 43}

      assert {:ok, %Grant{} = grant} = Grants.update_grant(grant, update_attrs)
      assert grant.deleted_at == ~N[2022-01-13 01:45:00]
      assert grant.organization_id == 43
      assert grant.role == "some updated role"
      assert grant.user_id == 43
    end

    test "update_grant/2 with invalid data returns error changeset" do
      grant = grant_fixture()
      assert {:error, %Ecto.Changeset{}} = Grants.update_grant(grant, @invalid_attrs)
      assert grant == Grants.get_grant!(grant.id)
    end

    test "delete_grant/1 deletes the grant" do
      grant = grant_fixture()
      assert {:ok, %Grant{}} = Grants.delete_grant(grant)
      assert_raise Ecto.NoResultsError, fn -> Grants.get_grant!(grant.id) end
    end

    test "change_grant/1 returns a grant changeset" do
      grant = grant_fixture()
      assert %Ecto.Changeset{} = Grants.change_grant(grant)
    end
  end
end
