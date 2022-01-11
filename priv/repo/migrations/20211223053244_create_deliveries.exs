defmodule Basic.Repo.Migrations.CreateDeliveries do
  use Ecto.Migration

  def change do
    create table(:deliveries) do
      add :order_id, :integer
      add :address_id, :integer
      add :phase, :string

      timestamps()
    end

  end
end
