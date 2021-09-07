defmodule Basic.Agents.Agent do
  use Ecto.Schema
  import Ecto.Changeset

  alias Basic.Agents

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
    |> validate_required([:user_id, :agency_id, :discount, :boost])
    |> validate_inclusion(:user_id, Agents.not_registered_user_ids(), message: "ユーザIDが無効です")
  end
end
