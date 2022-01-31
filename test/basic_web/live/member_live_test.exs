defmodule BasicWeb.MemberLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Basic.MembersFixtures

  @create_attrs %{birthday: %{day: 12, hour: 1, minute: 31, month: 1, year: 2022}, deleted_at: %{day: 12, hour: 1, minute: 31, month: 1, year: 2022}, department: "some department", detail: "some detail", first_name: "some first_name", first_name_kana: "some first_name_kana", image: "some image", industry: "some industry", last_name: "some last_name", last_name_kana: "some last_name_kana", organization_id: 42, organization_name: "some organization_name", position: "some position", user_id: 42}
  @update_attrs %{birthday: %{day: 13, hour: 1, minute: 31, month: 1, year: 2022}, deleted_at: %{day: 13, hour: 1, minute: 31, month: 1, year: 2022}, department: "some updated department", detail: "some updated detail", first_name: "some updated first_name", first_name_kana: "some updated first_name_kana", image: "some updated image", industry: "some updated industry", last_name: "some updated last_name", last_name_kana: "some updated last_name_kana", organization_id: 43, organization_name: "some updated organization_name", position: "some updated position", user_id: 43}
  @invalid_attrs %{birthday: %{day: 30, hour: 1, minute: 31, month: 2, year: 2022}, deleted_at: %{day: 30, hour: 1, minute: 31, month: 2, year: 2022}, department: nil, detail: nil, first_name: nil, first_name_kana: nil, image: nil, industry: nil, last_name: nil, last_name_kana: nil, organization_id: nil, organization_name: nil, position: nil, user_id: nil}

  defp create_member(_) do
    member = member_fixture()
    %{member: member}
  end

  describe "Index" do
    setup [:create_member]

    test "lists all members", %{conn: conn, member: member} do
      {:ok, _index_live, html} = live(conn, Routes.member_index_path(conn, :index))

      assert html =~ "Listing Members"
      assert html =~ member.department
    end

    test "saves new member", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.member_index_path(conn, :index))

      assert index_live |> element("a", "New Member") |> render_click() =~
               "New Member"

      assert_patch(index_live, Routes.member_index_path(conn, :new))

      assert index_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#member-form", member: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.member_index_path(conn, :index))

      assert html =~ "Member created successfully"
      assert html =~ "some department"
    end

    test "updates member in listing", %{conn: conn, member: member} do
      {:ok, index_live, _html} = live(conn, Routes.member_index_path(conn, :index))

      assert index_live |> element("#member-#{member.id} a", "Edit") |> render_click() =~
               "Edit Member"

      assert_patch(index_live, Routes.member_index_path(conn, :edit, member))

      assert index_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#member-form", member: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.member_index_path(conn, :index))

      assert html =~ "Member updated successfully"
      assert html =~ "some updated department"
    end

    test "deletes member in listing", %{conn: conn, member: member} do
      {:ok, index_live, _html} = live(conn, Routes.member_index_path(conn, :index))

      assert index_live |> element("#member-#{member.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#member-#{member.id}")
    end
  end

  describe "Show" do
    setup [:create_member]

    test "displays member", %{conn: conn, member: member} do
      {:ok, _show_live, html} = live(conn, Routes.member_show_path(conn, :show, member))

      assert html =~ "Show Member"
      assert html =~ member.department
    end

    test "updates member within modal", %{conn: conn, member: member} do
      {:ok, show_live, _html} = live(conn, Routes.member_show_path(conn, :show, member))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Member"

      assert_patch(show_live, Routes.member_show_path(conn, :edit, member))

      assert show_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#member-form", member: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.member_show_path(conn, :show, member))

      assert html =~ "Member updated successfully"
      assert html =~ "some updated department"
    end
  end
end
