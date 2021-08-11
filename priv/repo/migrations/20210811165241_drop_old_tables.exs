defmodule Basic.Repo.Migrations.DropOldTables do
  use Ecto.Migration

  def change do
    drop table(:members)
    drop table(:blogs)
  end
end
