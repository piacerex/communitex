defmodule Basic.Repo.Migrations.CreateAgencies do
  use Ecto.Migration

  def change do
    create table(:agencies) do
      add :brand, :string
      add :corporate_id, :integer
      add :distributor_id, :integer
      add :discount, :float
      add :boost, :float
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
