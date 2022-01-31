defmodule Basic.AgentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Agents` context.
  """

  @doc """
  Generate a agent.
  """
  def agent_fixture(attrs \\ %{}) do
    {:ok, agent} =
      attrs
      |> Enum.into(%{
        agency_id: 42,
        boost: 120.5,
        deleted_at: ~N[2022-01-12 01:51:00],
        discount: 120.5,
        user_id: 42
      })
      |> Basic.Agents.create_agent()

    agent
  end
end
