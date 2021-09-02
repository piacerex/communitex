defmodule Basic.Repo.Migrations.CreateContacts do
  use Ecto.Migration

  def change do
    create table(:contacts) do
      add :logined_user_id, :integer
      add :email, :string
      add :last_name, :string
      add :first_name, :string
      add :last_name_kana, :string
      add :first_name_kana, :string
      add :type, :string
      add :body, :text
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
