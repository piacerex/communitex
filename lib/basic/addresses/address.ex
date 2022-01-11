defmodule Basic.Addresses.Address do
  use Ecto.Schema
  import Ecto.Changeset

  schema "addresses" do
    field :address1, :string
    field :address2, :string
    field :city, :string
    field :first_name, :string
    field :last_name, :string
    field :postal, :string
    field :prefecture, :string
    field :tel, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(address, attrs) do
    address
    |> cast(attrs, [:user_id, :last_name, :first_name, :postal, :prefecture, :city, :address1, :address2, :tel])
    |> validate_required([:user_id, :last_name, :first_name, :postal, :prefecture, :city, :address1, :tel])
  end
end
