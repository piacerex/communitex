defmodule Basic.Orgatizations.Organization do
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :deleted_at, :naive_datetime
    field :name, :string
    field :postal, :string
    field :prefecture, :string
    field :tel, :string

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :postal, :prefecture, :city, :address1, :address2, :tel, :deleted_at])
    |> validate_required([:name, :postal, :prefecture, :city, :address1, :address2, :tel, :deleted_at])
  end
end
