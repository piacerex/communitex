defmodule BasicWeb.AgentLiveTest do
  use BasicWeb.ConnCase

  import Phoenix.LiveViewTest
  import Basic.AgentsFixtures

  @create_attrs %{agency_id: 42, boost: 120.5, deleted_at: %{day: 12, hour: 1, minute: 51, month: 1, year: 2022}, discount: 120.5, user_id: 42}
  @update_attrs %{agency_id: 43, boost: 456.7, deleted_at: %{day: 13, hour: 1, minute: 51, month: 1, year: 2022}, discount: 456.7, user_id: 43}
  @invalid_attrs %{agency_id: nil, boost: nil, deleted_at: %{day: 30, hour: 1, minute: 51, month: 2, year: 2022}, discount: nil, user_id: nil}

  defp create_agent(_) do
    agent = agent_fixture()
    %{agent: agent}
  end

  describe "Index" do
    setup [:create_agent]

    test "lists all agents", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, Routes.agent_index_path(conn, :index))

      assert html =~ "Listing Agents"
    end

    test "saves new agent", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.agent_index_path(conn, :index))

      assert index_live |> element("a", "New Agent") |> render_click() =~
               "New Agent"

      assert_patch(index_live, Routes.agent_index_path(conn, :new))

      assert index_live
             |> form("#agent-form", agent: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#agent-form", agent: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.agent_index_path(conn, :index))

      assert html =~ "Agent created successfully"
    end

    test "updates agent in listing", %{conn: conn, agent: agent} do
      {:ok, index_live, _html} = live(conn, Routes.agent_index_path(conn, :index))

      assert index_live |> element("#agent-#{agent.id} a", "Edit") |> render_click() =~
               "Edit Agent"

      assert_patch(index_live, Routes.agent_index_path(conn, :edit, agent))

      assert index_live
             |> form("#agent-form", agent: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        index_live
        |> form("#agent-form", agent: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.agent_index_path(conn, :index))

      assert html =~ "Agent updated successfully"
    end

    test "deletes agent in listing", %{conn: conn, agent: agent} do
      {:ok, index_live, _html} = live(conn, Routes.agent_index_path(conn, :index))

      assert index_live |> element("#agent-#{agent.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#agent-#{agent.id}")
    end
  end

  describe "Show" do
    setup [:create_agent]

    test "displays agent", %{conn: conn, agent: agent} do
      {:ok, _show_live, html} = live(conn, Routes.agent_show_path(conn, :show, agent))

      assert html =~ "Show Agent"
    end

    test "updates agent within modal", %{conn: conn, agent: agent} do
      {:ok, show_live, _html} = live(conn, Routes.agent_show_path(conn, :show, agent))

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Agent"

      assert_patch(show_live, Routes.agent_show_path(conn, :edit, agent))

      assert show_live
             |> form("#agent-form", agent: @invalid_attrs)
             |> render_change() =~ "is invalid"

      {:ok, _, html} =
        show_live
        |> form("#agent-form", agent: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.agent_show_path(conn, :show, agent))

      assert html =~ "Agent updated successfully"
    end
  end
end
