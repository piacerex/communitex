defmodule Basic.ContactsTest do
  use Basic.DataCase

  alias Basic.Contacts

  describe "contacts" do
    alias Basic.Contacts.Contact

    @valid_attrs %{body: "some body", deleted_at: ~N[2010-04-17 14:00:00], email: "some email", first_name: "some first_name", first_name_kana: "some first_name_kana", last_name: "some last_name", last_name_kana: "some last_name_kana", logined_user_id: 42, type: "some type"}
    @update_attrs %{body: "some updated body", deleted_at: ~N[2011-05-18 15:01:01], email: "some updated email", first_name: "some updated first_name", first_name_kana: "some updated first_name_kana", last_name: "some updated last_name", last_name_kana: "some updated last_name_kana", logined_user_id: 43, type: "some updated type"}
    @invalid_attrs %{body: nil, deleted_at: nil, email: nil, first_name: nil, first_name_kana: nil, last_name: nil, last_name_kana: nil, logined_user_id: nil, type: nil}

    def contact_fixture(attrs \\ %{}) do
      {:ok, contact} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contacts.create_contact()

      contact
    end

    test "list_contacts/0 returns all contacts" do
      contact = contact_fixture()
      assert Contacts.list_contacts() == [contact]
    end

    test "get_contact!/1 returns the contact with given id" do
      contact = contact_fixture()
      assert Contacts.get_contact!(contact.id) == contact
    end

    test "create_contact/1 with valid data creates a contact" do
      assert {:ok, %Contact{} = contact} = Contacts.create_contact(@valid_attrs)
      assert contact.body == "some body"
      assert contact.deleted_at == ~N[2010-04-17 14:00:00]
      assert contact.email == "some email"
      assert contact.first_name == "some first_name"
      assert contact.first_name_kana == "some first_name_kana"
      assert contact.last_name == "some last_name"
      assert contact.last_name_kana == "some last_name_kana"
      assert contact.logined_user_id == 42
      assert contact.type == "some type"
    end

    test "create_contact/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contacts.create_contact(@invalid_attrs)
    end

    test "update_contact/2 with valid data updates the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{} = contact} = Contacts.update_contact(contact, @update_attrs)
      assert contact.body == "some updated body"
      assert contact.deleted_at == ~N[2011-05-18 15:01:01]
      assert contact.email == "some updated email"
      assert contact.first_name == "some updated first_name"
      assert contact.first_name_kana == "some updated first_name_kana"
      assert contact.last_name == "some updated last_name"
      assert contact.last_name_kana == "some updated last_name_kana"
      assert contact.logined_user_id == 43
      assert contact.type == "some updated type"
    end

    test "update_contact/2 with invalid data returns error changeset" do
      contact = contact_fixture()
      assert {:error, %Ecto.Changeset{}} = Contacts.update_contact(contact, @invalid_attrs)
      assert contact == Contacts.get_contact!(contact.id)
    end

    test "delete_contact/1 deletes the contact" do
      contact = contact_fixture()
      assert {:ok, %Contact{}} = Contacts.delete_contact(contact)
      assert_raise Ecto.NoResultsError, fn -> Contacts.get_contact!(contact.id) end
    end

    test "change_contact/1 returns a contact changeset" do
      contact = contact_fixture()
      assert %Ecto.Changeset{} = Contacts.change_contact(contact)
    end
  end
end
