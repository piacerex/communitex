defmodule Basic.Repo.Migrations.CreateAgents do
  use Ecto.Migration

  def change do
    create table(:agents) do
      add :user_id, :integer
      add :agency_id, :integer
      add :discount, :float
      add :boost, :float
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
