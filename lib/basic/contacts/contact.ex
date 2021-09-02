defmodule Basic.Contacts.Contact do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contacts" do
    field :body, :string
    field :deleted_at, :naive_datetime
    field :email, :string
    field :first_name, :string
    field :first_name_kana, :string
    field :last_name, :string
    field :last_name_kana, :string
    field :logined_user_id, :integer
    field :type, :string

    timestamps()
  end

  @doc false
  def changeset(contact, attrs) do
    contact
    |> cast(attrs, [:logined_user_id, :email, :last_name, :first_name, :last_name_kana, :first_name_kana, :type, :body, :deleted_at])
    |> validate_required([:email, :last_name, :first_name, :last_name_kana, :first_name_kana, :type, :body])
  end
end
