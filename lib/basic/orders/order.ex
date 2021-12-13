defmodule Basic.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :deleted_at, :naive_datetime
    field :discount, :float
    field :is_cancel, :boolean, default: false
    field :item_id, :integer
    field :order_date, :naive_datetime
    field :price, :float
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:user_id, :item_id, :order_date, :price, :discount, :is_cancel, :deleted_at])
    |> validate_required([:user_id, :item_id, :order_date, :price, :discount, :is_cancel, :deleted_at])
  end
end
