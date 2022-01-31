defmodule Basic.BlogsTest do
  use Basic.DataCase

  alias Basic.Blogs

  describe "blogs" do
    alias Basic.Blogs.Blog

    import Basic.BlogsFixtures

    @invalid_attrs %{body: nil, deleted_at: nil, image: nil, likes: nil, post_id: nil, tags: nil, title: nil, user_id: nil, views: nil}

    test "list_blogs/0 returns all blogs" do
      blog = blog_fixture()
      assert Blogs.list_blogs() == [blog]
    end

    test "get_blog!/1 returns the blog with given id" do
      blog = blog_fixture()
      assert Blogs.get_blog!(blog.id) == blog
    end

    test "create_blog/1 with valid data creates a blog" do
      valid_attrs = %{body: "some body", deleted_at: ~N[2022-01-12 01:43:00], image: "some image", likes: 42, post_id: "some post_id", tags: "some tags", title: "some title", user_id: 42, views: 42}

      assert {:ok, %Blog{} = blog} = Blogs.create_blog(valid_attrs)
      assert blog.body == "some body"
      assert blog.deleted_at == ~N[2022-01-12 01:43:00]
      assert blog.image == "some image"
      assert blog.likes == 42
      assert blog.post_id == "some post_id"
      assert blog.tags == "some tags"
      assert blog.title == "some title"
      assert blog.user_id == 42
      assert blog.views == 42
    end

    test "create_blog/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Blogs.create_blog(@invalid_attrs)
    end

    test "update_blog/2 with valid data updates the blog" do
      blog = blog_fixture()
      update_attrs = %{body: "some updated body", deleted_at: ~N[2022-01-13 01:43:00], image: "some updated image", likes: 43, post_id: "some updated post_id", tags: "some updated tags", title: "some updated title", user_id: 43, views: 43}

      assert {:ok, %Blog{} = blog} = Blogs.update_blog(blog, update_attrs)
      assert blog.body == "some updated body"
      assert blog.deleted_at == ~N[2022-01-13 01:43:00]
      assert blog.image == "some updated image"
      assert blog.likes == 43
      assert blog.post_id == "some updated post_id"
      assert blog.tags == "some updated tags"
      assert blog.title == "some updated title"
      assert blog.user_id == 43
      assert blog.views == 43
    end

    test "update_blog/2 with invalid data returns error changeset" do
      blog = blog_fixture()
      assert {:error, %Ecto.Changeset{}} = Blogs.update_blog(blog, @invalid_attrs)
      assert blog == Blogs.get_blog!(blog.id)
    end

    test "delete_blog/1 deletes the blog" do
      blog = blog_fixture()
      assert {:ok, %Blog{}} = Blogs.delete_blog(blog)
      assert_raise Ecto.NoResultsError, fn -> Blogs.get_blog!(blog.id) end
    end

    test "change_blog/1 returns a blog changeset" do
      blog = blog_fixture()
      assert %Ecto.Changeset{} = Blogs.change_blog(blog)
    end
  end
end
