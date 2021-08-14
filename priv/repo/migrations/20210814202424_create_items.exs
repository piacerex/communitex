defmodule Basic.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string
      add :detail, :text
      add :image, :text
      add :distributor_id, :integer
      add :price, :float
      add :start_date, :naive_datetime
      add :end_date, :naive_datetime
      add :open_date, :naive_datetime
      add :close_date, :naive_datetime
      add :is_open, :boolean, default: false, null: false
      add :area, :string
      add :occupation, :string
      add :alls, :integer
      add :stocks, :integer
      add :deleted_at, :naive_datetime

      timestamps()
    end

  end
end
