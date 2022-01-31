defmodule Basic.MembersTest do
  use Basic.DataCase

  alias Basic.Members

  describe "members" do
    alias Basic.Members.Member

    import Basic.MembersFixtures

    @invalid_attrs %{birthday: nil, deleted_at: nil, department: nil, detail: nil, first_name: nil, first_name_kana: nil, image: nil, industry: nil, last_name: nil, last_name_kana: nil, organization_id: nil, organization_name: nil, position: nil, user_id: nil}

    test "list_members/0 returns all members" do
      member = member_fixture()
      assert Members.list_members() == [member]
    end

    test "get_member!/1 returns the member with given id" do
      member = member_fixture()
      assert Members.get_member!(member.id) == member
    end

    test "create_member/1 with valid data creates a member" do
      valid_attrs = %{birthday: ~N[2022-01-12 01:31:00], deleted_at: ~N[2022-01-12 01:31:00], department: "some department", detail: "some detail", first_name: "some first_name", first_name_kana: "some first_name_kana", image: "some image", industry: "some industry", last_name: "some last_name", last_name_kana: "some last_name_kana", organization_id: 42, organization_name: "some organization_name", position: "some position", user_id: 42}

      assert {:ok, %Member{} = member} = Members.create_member(valid_attrs)
      assert member.birthday == ~N[2022-01-12 01:31:00]
      assert member.deleted_at == ~N[2022-01-12 01:31:00]
      assert member.department == "some department"
      assert member.detail == "some detail"
      assert member.first_name == "some first_name"
      assert member.first_name_kana == "some first_name_kana"
      assert member.image == "some image"
      assert member.industry == "some industry"
      assert member.last_name == "some last_name"
      assert member.last_name_kana == "some last_name_kana"
      assert member.organization_id == 42
      assert member.organization_name == "some organization_name"
      assert member.position == "some position"
      assert member.user_id == 42
    end

    test "create_member/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_member(@invalid_attrs)
    end

    test "update_member/2 with valid data updates the member" do
      member = member_fixture()
      update_attrs = %{birthday: ~N[2022-01-13 01:31:00], deleted_at: ~N[2022-01-13 01:31:00], department: "some updated department", detail: "some updated detail", first_name: "some updated first_name", first_name_kana: "some updated first_name_kana", image: "some updated image", industry: "some updated industry", last_name: "some updated last_name", last_name_kana: "some updated last_name_kana", organization_id: 43, organization_name: "some updated organization_name", position: "some updated position", user_id: 43}

      assert {:ok, %Member{} = member} = Members.update_member(member, update_attrs)
      assert member.birthday == ~N[2022-01-13 01:31:00]
      assert member.deleted_at == ~N[2022-01-13 01:31:00]
      assert member.department == "some updated department"
      assert member.detail == "some updated detail"
      assert member.first_name == "some updated first_name"
      assert member.first_name_kana == "some updated first_name_kana"
      assert member.image == "some updated image"
      assert member.industry == "some updated industry"
      assert member.last_name == "some updated last_name"
      assert member.last_name_kana == "some updated last_name_kana"
      assert member.organization_id == 43
      assert member.organization_name == "some updated organization_name"
      assert member.position == "some updated position"
      assert member.user_id == 43
    end

    test "update_member/2 with invalid data returns error changeset" do
      member = member_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.update_member(member, @invalid_attrs)
      assert member == Members.get_member!(member.id)
    end

    test "delete_member/1 deletes the member" do
      member = member_fixture()
      assert {:ok, %Member{}} = Members.delete_member(member)
      assert_raise Ecto.NoResultsError, fn -> Members.get_member!(member.id) end
    end

    test "change_member/1 returns a member changeset" do
      member = member_fixture()
      assert %Ecto.Changeset{} = Members.change_member(member)
    end
  end
end
