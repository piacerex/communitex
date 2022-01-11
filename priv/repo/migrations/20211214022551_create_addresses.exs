defmodule Basic.Repo.Migrations.CreateAddresses do
  use Ecto.Migration

  def change do
    create table(:addresses) do
      add :user_id, :integer
      add :last_name, :string
      add :first_name, :string
      add :postal, :string
      add :prefecture, :string
      add :city, :string
      add :address1, :string
      add :address2, :string
      add :tel, :string

      timestamps()
    end

  end
end
