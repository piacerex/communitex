defmodule BasicWeb.MemberLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Basic.Members

  @create_attrs %{birthday: ~N[2010-04-17 14:00:00], organization_id: 42, organization_name: "some organization_name", deleted_at: ~N[2010-04-17 14:00:00], department: "some department", detail: "some detail", first_name: "some first_name", first_name_kana: "some first_name_kana", image: "some image", industry: "some industry", last_name: "some last_name", last_name_kana: "some last_name_kana", position: "some position", user_id: 42}
  @update_attrs %{birthday: ~N[2011-05-18 15:01:01], organization_id: 43, organization_name: "some updated organization_name", deleted_at: ~N[2011-05-18 15:01:01], department: "some updated department", detail: "some updated detail", first_name: "some updated first_name", first_name_kana: "some updated first_name_kana", image: "some updated image", industry: "some updated industry", last_name: "some updated last_name", last_name_kana: "some updated last_name_kana", position: "some updated position", user_id: 43}
  @invalid_attrs %{birthday: nil, organization_id: nil, organization_name: nil, deleted_at: nil, department: nil, detail: nil, first_name: nil, first_name_kana: nil, image: nil, industry: nil, last_name: nil, last_name_kana: nil, position: nil, user_id: nil}

  defp fixture(:member) do
    {:ok, member} = Members.create_member(@create_attrs)
    member
  end

  defp create_member(_) do
    member = fixture(:member)
    %{member: member}
  end

  describe "Index" do
    setup [:create_member]

    test "lists all members", %{conn: conn, member: member} do
      {:ok, _index_live, html} = live(conn, Routes.member_index_path(conn, :index))

      assert html =~ "Listing Members"
      assert html =~ member.organization_name
    end

    test "saves new member", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.member_index_path(conn, :index))

      assert index_live |> element("a", "New Member") |> render_click() =~
               "New Member"

      assert_patch(index_live, Routes.member_index_path(conn, :new))

      assert index_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#member-form", member: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.member_index_path(conn, :index))

      assert html =~ "Member created successfully"
      assert html =~ "some organization_name"
    end

    test "updates member in listing", %{conn: conn, member: member} do
      {:ok, index_live, _html} = live(conn, Routes.member_index_path(conn, :index))

      assert index_live |> element("#member-#{member.id} a", "Edit") |> render_click() =~
               "Edit Member"

      assert_patch(index_live, Routes.member_index_path(conn, :edit, member))

      assert index_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#member-form", member: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.member_index_path(conn, :index))

      assert html =~ "Member updated successfully"
      assert html =~ "some updated organization_name"
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
      assert html =~ member.organization_name
    end

    test "updates member within modal", %{conn: conn, member: member} do
      {:ok, show_live, _html} = live(conn, Routes.member_show_path(conn, :show, member))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Member"

      assert_patch(show_live, Routes.member_show_path(conn, :edit, member))

      assert show_live
             |> form("#member-form", member: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#member-form", member: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.member_show_path(conn, :show, member))

      assert html =~ "Member updated successfully"
      assert html =~ "some updated organization_name"
    end
  end
end
