defmodule Basic.AgentsTest do
  use Basic.DataCase

  alias Basic.Agents

  describe "agents" do
    alias Basic.Agents.Agent

    import Basic.AgentsFixtures

    @invalid_attrs %{agency_id: nil, boost: nil, deleted_at: nil, discount: nil, user_id: nil}

    test "list_agents/0 returns all agents" do
      agent = agent_fixture()
      assert Agents.list_agents() == [agent]
    end

    test "get_agent!/1 returns the agent with given id" do
      agent = agent_fixture()
      assert Agents.get_agent!(agent.id) == agent
    end

    test "create_agent/1 with valid data creates a agent" do
      valid_attrs = %{agency_id: 42, boost: 120.5, deleted_at: ~N[2022-01-12 01:51:00], discount: 120.5, user_id: 42}

      assert {:ok, %Agent{} = agent} = Agents.create_agent(valid_attrs)
      assert agent.agency_id == 42
      assert agent.boost == 120.5
      assert agent.deleted_at == ~N[2022-01-12 01:51:00]
      assert agent.discount == 120.5
      assert agent.user_id == 42
    end

    test "create_agent/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Agents.create_agent(@invalid_attrs)
    end

    test "update_agent/2 with valid data updates the agent" do
      agent = agent_fixture()
      update_attrs = %{agency_id: 43, boost: 456.7, deleted_at: ~N[2022-01-13 01:51:00], discount: 456.7, user_id: 43}

      assert {:ok, %Agent{} = agent} = Agents.update_agent(agent, update_attrs)
      assert agent.agency_id == 43
      assert agent.boost == 456.7
      assert agent.deleted_at == ~N[2022-01-13 01:51:00]
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
