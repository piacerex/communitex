defmodule Basic.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :user_id, :integer
      add :item_id, :integer
      add :order_date, :date
      add :price, :float
      add :discount, :float
      add :is_cancel, :boolean, default: false, null: false
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
