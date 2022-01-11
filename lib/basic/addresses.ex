defmodule Basic.Addresses do
  @moduledoc """
  The Addresses context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Addresses.Address

  @doc """
  Returns the list of addresses.

  ## Examples

      iex> list_addresses()
      [%Address{}, ...]

  """
  def list_addresses do
    Repo.all(Address)
  end

  def list_addresses_for_user(user_id, id) do
    lists = from( address in Address,
                  where: address.user_id == ^user_id
                ) |> Repo.all

    Enum.concat(Enum.reject(lists, fn x -> x.id != String.to_integer(id) end), Enum.reject(lists, fn x -> x.id == String.to_integer(id) end))
  end

  def list_addresses_for_user(user_id) do
    from( address in Address,
          where: address.user_id == ^user_id
    ) |> Repo.all
  end

  @doc """
  Gets a single address.

  Raises `Ecto.NoResultsError` if the Address does not exist.

  ## Examples

      iex> get_address!(123)
      %Address{}

      iex> get_address!(456)
      ** (Ecto.NoResultsError)

  """
  def get_address!(id), do: Repo.get!(Address, id)

  def registered_address_id(params) do
    data = from( address in Address,
                 where: address.user_id == ^params["user_id"] and
                        address.postal == ^params["postal"] and
                        address.prefecture == ^params["prefecture"] and
                        address.city == ^params["city"] and
                        address.address1 == ^params["address1"] and
                        address.tel == ^params["tel"]
    ) |> Repo.all
    case data do
      [] -> -1
      _ -> List.first(data).id
    end
  end

  @doc """
  Creates a address.

  ## Examples

      iex> create_address(%{field: value})
      {:ok, %Address{}}

      iex> create_address(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_address(attrs \\ %{}) do
    %Address{}
    |> Address.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a address.

  ## Examples

      iex> update_address(address, %{field: new_value})
      {:ok, %Address{}}

      iex> update_address(address, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_address(%Address{} = address, attrs) do
    address
    |> Address.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a address.

  ## Examples

      iex> delete_address(address)
      {:ok, %Address{}}

      iex> delete_address(address)
      {:error, %Ecto.Changeset{}}

  """
  def delete_address(%Address{} = address) do
    Repo.delete(address)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking address changes.

  ## Examples

      iex> change_address(address)
      %Ecto.Changeset{data: %Address{}}

  """
  def change_address(%Address{} = address, attrs \\ %{}) do
    Address.changeset(address, attrs)
  end
end
