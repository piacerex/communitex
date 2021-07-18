defmodule Basic.Members.Member do
  use Ecto.Schema
  import Ecto.Changeset

  schema "members" do
    field :birthday, :naive_datetime
    field :corporate_id, :integer
    field :corporate_name, :string
    field :deleted_at, :naive_datetime
    field :department, :string
    field :detail, :string
    field :first_name, :string
    field :first_name_kana, :string
    field :image, :string
    field :industry, :string
    field :last_name, :string
    field :last_name_kana, :string
    field :position, :string
    field :user_id, :integer

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :last_name, :first_name, :last_name_kana, :first_name_kana, :detail, :image, :birthday, :corporate_id, :corporate_name, :industry, :department, :position, :deleted_at])
    |> validate_required([:user_id, :last_name, :first_name, :last_name_kana, :first_name_kana, :detail, :image, :birthday, :corporate_id, :corporate_name, :industry, :department, :position, :deleted_at])
  end
end
