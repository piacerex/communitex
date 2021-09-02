defmodule Basic.Repo.Migrations.AlterMembers do
  use Ecto.Migration

  def change do
    alter table("members") do
      remove_if_exists :corporate_id, :integer
      remove_if_exists :corporate_name, :string
      add_if_not_exists :organization_id, :integer
      add_if_not_exists :organization_name, :string
    end
  end
end
