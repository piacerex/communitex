defmodule Basic.Distributors.Distributor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "distributors" do
    field :brand, :string
    field :corporate_id, :integer
    field :deleted_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(distributor, attrs) do
    distributor
    |> cast(attrs, [:brand, :corporate_id, :deleted_at])
    |> validate_required([:brand, :corporate_id])
  end
end
