defmodule Basic.Repo.Migrations.CreateGrants do
  use Ecto.Migration

  def change do
    create table(:grants) do
      add :user_id, :integer
      add :organization_id, :integer
      add :role, :string
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
