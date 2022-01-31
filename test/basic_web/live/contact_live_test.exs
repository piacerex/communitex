defmodule BasicWeb.ContactLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Basic.ContactsFixtures

  @create_attrs %{body: "some body", deleted_at: %{day: 12, hour: 1, minute: 52, month: 1, year: 2022}, email: "some email", first_name: "some first_name", first_name_kana: "some first_name_kana", last_name: "some last_name", last_name_kana: "some last_name_kana", logined_user_id: 42, type: "some type"}
  @update_attrs %{body: "some updated body", deleted_at: %{day: 13, hour: 1, minute: 52, month: 1, year: 2022}, email: "some updated email", first_name: "some updated first_name", first_name_kana: "some updated first_name_kana", last_name: "some updated last_name", last_name_kana: "some updated last_name_kana", logined_user_id: 43, type: "some updated type"}
  @invalid_attrs %{body: nil, deleted_at: %{day: 30, hour: 1, minute: 52, month: 2, year: 2022}, email: nil, first_name: nil, first_name_kana: nil, last_name: nil, last_name_kana: nil, logined_user_id: nil, type: nil}

  defp create_contact(_) do
    contact = contact_fixture()
    %{contact: contact}
  end

  describe "Index" do
    setup [:create_contact]

    test "lists all contacts", %{conn: conn, contact: contact} do
      {:ok, _index_live, html} = live(conn, Routes.contact_index_path(conn, :index))

      assert html =~ "Listing Contacts"
      assert html =~ contact.body
    end

    test "saves new contact", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.contact_index_path(conn, :index))

      assert index_live |> element("a", "New Contact") |> render_click() =~
               "New Contact"

      assert_patch(index_live, Routes.contact_index_path(conn, :new))

      assert index_live
             |> form("#contact-form", contact: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#contact-form", contact: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.contact_index_path(conn, :index))

      assert html =~ "Contact created successfully"
      assert html =~ "some body"
    end

    test "updates contact in listing", %{conn: conn, contact: contact} do
      {:ok, index_live, _html} = live(conn, Routes.contact_index_path(conn, :index))

      assert index_live |> element("#contact-#{contact.id} a", "Edit") |> render_click() =~
               "Edit Contact"

      assert_patch(index_live, Routes.contact_index_path(conn, :edit, contact))

      assert index_live
             |> form("#contact-form", contact: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#contact-form", contact: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.contact_index_path(conn, :index))

      assert html =~ "Contact updated successfully"
      assert html =~ "some updated body"
    end

    test "deletes contact in listing", %{conn: conn, contact: contact} do
      {:ok, index_live, _html} = live(conn, Routes.contact_index_path(conn, :index))

      assert index_live |> element("#contact-#{contact.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#contact-#{contact.id}")
    end
  end

  describe "Show" do
    setup [:create_contact]

    test "displays contact", %{conn: conn, contact: contact} do
      {:ok, _show_live, html} = live(conn, Routes.contact_show_path(conn, :show, contact))

      assert html =~ "Show Contact"
      assert html =~ contact.body
    end

    test "updates contact within modal", %{conn: conn, contact: contact} do
      {:ok, show_live, _html} = live(conn, Routes.contact_show_path(conn, :show, contact))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Contact"

      assert_patch(show_live, Routes.contact_show_path(conn, :edit, contact))

      assert show_live
             |> form("#contact-form", contact: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#contact-form", contact: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.contact_show_path(conn, :show, contact))

      assert html =~ "Contact updated successfully"
      assert html =~ "some updated body"
    end
  end
end
