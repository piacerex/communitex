defmodule Basic.Repo.Migrations.DropOldTables do
  use Ecto.Migration

  def change do
    drop_if_exists table(:members)
    drop_if_exists table(:blogs)
  end
end
