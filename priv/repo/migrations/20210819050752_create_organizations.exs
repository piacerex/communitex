defmodule Basic.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
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
