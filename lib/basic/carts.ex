defmodule Basic.Carts do
  @moduledoc """
  The Carts context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Carts.Cart
  alias Basic.Items.Item

  @doc """
  Returns the list of carts.

  ## Examples

      iex> list_carts()
      [%Cart{}, ...]

  """
  def list_carts do
    Repo.all(Cart)
  end

  @doc """
  Gets a single cart.

  Raises `Ecto.NoResultsError` if the Cart does not exist.

  ## Examples

      iex> get_cart!(123)
      %Cart{}

      iex> get_cart!(456)
      ** (Ecto.NoResultsError)

  """
  def get_cart!(id), do: Repo.get!(Cart, id)

  @doc """
  Creates a cart.

  ## Examples

      iex> create_cart(%{field: value})
      {:ok, %Cart{}}

      iex> create_cart(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_cart(attrs \\ %{}) do
    %Cart{}
    |> Cart.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a cart.

  ## Examples

      iex> update_cart(cart, %{field: new_value})
      {:ok, %Cart{}}

      iex> update_cart(cart, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_cart(%Cart{} = cart, attrs) do
    cart
    |> Cart.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a cart.

  ## Examples

      iex> delete_cart(cart)
      {:ok, %Cart{}}

      iex> delete_cart(cart)
      {:error, %Ecto.Changeset{}}

  """
  def delete_cart(%Cart{} = cart) do
    Repo.delete(cart)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking cart changes.

  ## Examples

      iex> change_cart(cart)
      %Ecto.Changeset{data: %Cart{}}

  """
  def change_cart(%Cart{} = cart, attrs \\ %{}) do
    Cart.changeset(cart, attrs)
  end

  def list_carts_for_user(user_id) do
    case user_id do
      "" -> []
      _ ->
        items = from item in Item
        from( cart in Cart,
              where: cart.user_id == ^user_id and cart.is_order == false,
              join: item in ^items,
              on: [id: cart.item_id],
              select: [
                map(cart, ^Cart.__schema__(:fields)),
                map(item, ^Item.__schema__(:fields))
              ]
        )
        |> Repo.all
    end
  end

  def get_cart_by_user_and_item(user_id, item_id) do
    from( cart in Cart,
          where: cart.user_id == ^user_id and
                 cart.item_id == ^item_id and
                 cart.is_order == ^false
    )
    |> Repo.all
    |> List.first
  end

  def get_item_name(id) do
    choice_cart = from( cart in Cart,
                        where: cart.id == ^id
                  )|> Repo.all
    item_info = from( item in Item,
                      where: item.id == ^List.first(choice_cart).item_id
                )|> Repo.all

    List.first(item_info).name
  end
end
