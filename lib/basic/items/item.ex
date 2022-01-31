defmodule Basic.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :alls, :integer
    field :area, :string
    field :close_date, :naive_datetime
    field :deleted_at, :naive_datetime
    field :delivery_require, :boolean, default: false
    field :detail, :string
    field :distributor_id, :integer
    field :end_date, :naive_datetime
    field :image, :string
    field :is_open, :boolean, default: false
    field :name, :string
    field :occupation, :string
    field :open_date, :naive_datetime
    field :payment_cycle, :string
    field :price, :float
    field :start_date, :naive_datetime
    field :stocks, :integer

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :detail, :image, :distributor_id, :price, :start_date, :end_date, :open_date, :close_date, :is_open, :area, :occupation, :alls, :stocks, :payment_cycle, :delivery_require, :deleted_at])
    |> validate_required([:name, :price])
  end
end
