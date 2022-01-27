defmodule Basic.Agencies.Agency do
  use Ecto.Schema
  import Ecto.Changeset

  schema "agencies" do
    field :boost, :float
    field :brand, :string
    field :deleted_at, :naive_datetime
    field :discount, :float
    field :distributor_id, :integer
    field :organization_id, :integer

    timestamps()
  end

  @doc false
  def changeset(agency, attrs) do
    agency
    |> cast(attrs, [:brand, :organization_id, :distributor_id, :discount, :boost, :deleted_at])
    |> validate_required([:brand, :organization_id, :distributor_id, :discount, :boost])
  end
end
