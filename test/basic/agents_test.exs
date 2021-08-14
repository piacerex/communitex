defmodule Basic.AgentsTest do
  use Basic.DataCase

  alias Basic.Agents

  describe "agents" do
    alias Basic.Agents.Agent

    @valid_attrs %{agency_id: 42, boost: 120.5, deleted_at: ~N[2010-04-17 14:00:00], discount: 120.5, user_id: 42}
    @update_attrs %{agency_id: 43, boost: 456.7, deleted_at: ~N[2011-05-18 15:01:01], discount: 456.7, user_id: 43}
    @invalid_attrs %{agency_id: nil, boost: nil, deleted_at: nil, discount: nil, user_id: nil}

    def agent_fixture(attrs \\ %{}) do
      {:ok, agent} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Agents.create_agent()

      agent
    end

    test "list_agents/0 returns all agents" do
      agent = agent_fixture()
      assert Agents.list_agents() == [agent]
    end

    test "get_agent!/1 returns the agent with given id" do
      agent = agent_fixture()
      assert Agents.get_agent!(agent.id) == agent
    end

    test "create_agent/1 with valid data creates a agent" do
      assert {:ok, %Agent{} = agent} = Agents.create_agent(@valid_attrs)
      assert agent.agency_id == 42
      assert agent.boost == 120.5
      assert agent.deleted_at == ~N[2010-04-17 14:00:00]
      assert agent.discount == 120.5
      assert agent.user_id == 42
    end

    test "create_agent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agents.create_agent(@invalid_attrs)
    end

    test "update_agent/2 with valid data updates the agent" do
      agent = agent_fixture()
      assert {:ok, %Agent{} = agent} = Agents.update_agent(agent, @update_attrs)
      assert agent.agency_id == 43
      assert agent.boost == 456.7
      assert agent.deleted_at == ~N[2011-05-18 15:01:01]
      assert agent.discount == 456.7
      assert agent.user_id == 43
    end

    test "update_agent/2 with invalid data returns error changeset" do
      agent = agent_fixture()
      assert {:error, %Ecto.Changeset{}} = Agents.update_agent(agent, @invalid_attrs)
      assert agent == Agents.get_agent!(agent.id)
    end

    test "delete_agent/1 deletes the agent" do
      agent = agent_fixture()
      assert {:ok, %Agent{}} = Agents.delete_agent(agent)
      assert_raise Ecto.NoResultsError, fn -> Agents.get_agent!(agent.id) end
    end

    test "change_agent/1 returns a agent changeset" do
      agent = agent_fixture()
      assert %Ecto.Changeset{} = Agents.change_agent(agent)
    end
  end
end
