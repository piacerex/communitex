defmodule Basic.Repo.Migrations.CreateBlogs do
  use Ecto.Migration

  def change do
    create table(:blogs) do
      add :post_id, :string
      add :user_id, :integer
      add :title, :string
      add :image, :binary
      add :tags, :string
      add :body, :text
      add :likes, :integer
      add :views, :integer
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
