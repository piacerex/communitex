defmodule Basic.Repo.Migrations.CreateDistributors do
  use Ecto.Migration

  def change do
    create table(:distributors) do
      add :brand, :string
      add :organization_id, :integer
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
