defmodule Basic.Repo.Migrations.CreateCarts do
  use Ecto.Migration

  def change do
    create table(:carts) do
      add :user_id, :integer
      add :item_id, :integer
      add :quantity, :integer
      add :is_order, :boolean, default: false, null: false

      timestamps()
    end

  end
end
