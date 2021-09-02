defmodule Basic.Repo.Migrations.DropOldCorporateRelatedTables do
  use Ecto.Migration

  def change do
    drop_if_exists table(:corporates)
    drop_if_exists table(:agencies)
    drop_if_exists table(:distributors)
    drop_if_exists table(:grants)
  end
end
