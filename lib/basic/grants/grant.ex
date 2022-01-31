defmodule Basic.Grants.Grant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "grants" do
    field :deleted_at, :naive_datetime
    field :organization_id, :integer
    field :role, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(grant, attrs) do
    grant
    |> cast(attrs, [:user_id, :organization_id, :role, :deleted_at])
    |> validate_required([:user_id, :organization_id, :role])
  end
end
