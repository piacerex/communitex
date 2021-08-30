defmodule Basic.Repo.Migrations.DropOldCorporateRelatedTables do
  use Ecto.Migration

  def change do
    drop_if_exists table(:corporates)
  end
end
