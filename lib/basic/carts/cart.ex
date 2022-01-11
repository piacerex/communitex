defmodule Basic.Carts.Cart do
  use Ecto.Schema
  import Ecto.Changeset

  schema "carts" do
    field :is_order, :boolean, default: false
    field :item_id, :integer
    field :quantity, :integer
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(cart, attrs) do
    cart
    |> cast(attrs, [:user_id, :item_id, :quantity, :is_order])
    |> validate_required([:user_id, :item_id, :quantity, :is_order])
  end
end
