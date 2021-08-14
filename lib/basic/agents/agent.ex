defmodule Basic.Agents.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agents" do
    field :agency_id, :integer
    field :boost, :float
    field :deleted_at, :naive_datetime
    field :discount, :float
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:user_id, :agency_id, :discount, :boost, :deleted_at])
    |> validate_required([:user_id, :agency_id, :discount, :boost, :deleted_at])
  end
end
