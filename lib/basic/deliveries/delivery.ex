defmodule Basic.Deliveries.Delivery do
  use Ecto.Schema
  import Ecto.Changeset

  schema "deliveries" do
    field :address_id, :integer
    field :order_id, :integer
    field :order_number, :string
    field :phase, :string

    timestamps()
  end

  @doc false
  def changeset(delivery, attrs) do
    delivery
    |> cast(attrs, [:order_id, :address_id, :phase, :order_number])
    |> validate_required([:order_id, :address_id, :phase])
  end
end
