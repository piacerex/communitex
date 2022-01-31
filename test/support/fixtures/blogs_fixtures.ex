defmodule Basic.BlogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Basic.Blogs` context.
  """

  @doc """
  Generate a blog.
  """
  def blog_fixture(attrs \\ %{}) do
    {:ok, blog} =
      attrs
      |> Enum.into(%{
        body: "some body",
        deleted_at: ~N[2022-01-12 01:43:00],
        image: "some image",
        likes: 42,
        post_id: "some post_id",
        tags: "some tags",
        title: "some title",
        user_id: 42,
        views: 42
      })
      |> Basic.Blogs.create_blog()

    blog
  end
end
