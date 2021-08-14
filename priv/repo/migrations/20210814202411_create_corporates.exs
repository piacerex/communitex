defmodule Basic.Repo.Migrations.CreateCorporates do
  use Ecto.Migration

  def change do
    create table(:corporates) do
      add :name, :string
      add :postal, :string
      add :prefecture, :string
      add :city, :string
      add :address1, :string
      add :address2, :string
      add :tel, :string
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
