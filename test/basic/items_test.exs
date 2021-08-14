defmodule Basic.ItemsTest do
  use Basic.DataCase

  alias Basic.Items

  describe "items" do
    alias Basic.Items.Item

    @valid_attrs %{alls: 42, area: "some area", close_date: ~N[2010-04-17 14:00:00], deleted_at: ~N[2010-04-17 14:00:00], detail: "some detail", distributor_id: 42, end_date: ~N[2010-04-17 14:00:00], image: "some image", is_open: true, name: "some name", occupation: "some occupation", open_date: ~N[2010-04-17 14:00:00], price: 120.5, start_date: ~N[2010-04-17 14:00:00], stocks: 42}
    @update_attrs %{alls: 43, area: "some updated area", close_date: ~N[2011-05-18 15:01:01], deleted_at: ~N[2011-05-18 15:01:01], detail: "some updated detail", distributor_id: 43, end_date: ~N[2011-05-18 15:01:01], image: "some updated image", is_open: false, name: "some updated name", occupation: "some updated occupation", open_date: ~N[2011-05-18 15:01:01], price: 456.7, start_date: ~N[2011-05-18 15:01:01], stocks: 43}
    @invalid_attrs %{alls: nil, area: nil, close_date: nil, deleted_at: nil, detail: nil, distributor_id: nil, end_date: nil, image: nil, is_open: nil, name: nil, occupation: nil, open_date: nil, price: nil, start_date: nil, stocks: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Items.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Items.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Items.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Items.create_item(@valid_attrs)
      assert item.alls == 42
      assert item.area == "some area"
      assert item.close_date == ~N[2010-04-17 14:00:00]
      assert item.deleted_at == ~N[2010-04-17 14:00:00]
      assert item.detail == "some detail"
      assert item.distributor_id == 42
      assert item.end_date == ~N[2010-04-17 14:00:00]
      assert item.image == "some image"
      assert item.is_open == true
      assert item.name == "some name"
      assert item.occupation == "some occupation"
      assert item.open_date == ~N[2010-04-17 14:00:00]
      assert item.price == 120.5
      assert item.start_date == ~N[2010-04-17 14:00:00]
      assert item.stocks == 42
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Items.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, %Item{} = item} = Items.update_item(item, @update_attrs)
      assert item.alls == 43
      assert item.area == "some updated area"
      assert item.close_date == ~N[2011-05-18 15:01:01]
      assert item.deleted_at == ~N[2011-05-18 15:01:01]
      assert item.detail == "some updated detail"
      assert item.distributor_id == 43
      assert item.end_date == ~N[2011-05-18 15:01:01]
      assert item.image == "some updated image"
      assert item.is_open == false
      assert item.name == "some updated name"
      assert item.occupation == "some updated occupation"
      assert item.open_date == ~N[2011-05-18 15:01:01]
      assert item.price == 456.7
      assert item.start_date == ~N[2011-05-18 15:01:01]
      assert item.stocks == 43
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Items.update_item(item, @invalid_attrs)
      assert item == Items.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Items.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Items.change_item(item)
    end
  end
end
