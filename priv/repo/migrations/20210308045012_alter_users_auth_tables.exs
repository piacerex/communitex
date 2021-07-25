defmodule Basic.Repo.Migrations.AlterUsersAuthTables do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :deleted_at, :naive_datetime
    end
  end
end
