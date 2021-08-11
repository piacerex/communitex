defmodule Basic.Blogs.Blog do
  use Ecto.Schema
  import Ecto.Changeset

  schema "blogs" do
    field :body, :string
    field :deleted_at, :naive_datetime
    field :image, :string
    field :likes, :integer
    field :post_id, :string
    field :tags, :string
    field :title, :string
    field :user_id, :integer
    field :views, :integer

    timestamps()
  end

  @doc false
  def changeset(blog, attrs) do
    blog
    |> cast(attrs, [:post_id, :user_id, :title, :image, :tags, :body, :likes, :views, :deleted_at])
    |> validate_required([:post_id, :user_id, :title, :image, :tags, :body, :likes, :views, :deleted_at])
  end
end
