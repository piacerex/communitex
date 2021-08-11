defmodule Basic.Repo.Migrations.CreateMembers do
  use Ecto.Migration

  def change do
    create table(:members) do
      add :user_id, :integer
      add :last_name, :string
      add :first_name, :string
      add :last_name_kana, :string
      add :first_name_kana, :string
      add :detail, :text
      add :image, :text
      add :birthday, :naive_datetime
      add :corporate_id, :integer
      add :corporate_name, :string
      add :industry, :string
      add :department, :string
      add :position, :string
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
