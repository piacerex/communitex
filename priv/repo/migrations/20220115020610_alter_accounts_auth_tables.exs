defmodule Basic.Repo.Migrations.AlterAccountsAuthTables do
  use Ecto.Migration

  def change do
    alter table(:accounts) do
      add :deleted_at, :naive_datetime
    end
  end
end
