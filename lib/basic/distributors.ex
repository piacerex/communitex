defmodule Basic.Distributors do
  @moduledoc """
  The Distributors context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Distributors.Distributor

  @doc """
  Returns the list of distributors.

  ## Examples

      iex> list_distributors()
      [%Distributor{}, ...]

  """
  def list_distributors do
    Repo.all(Distributor)
  end

  @doc """
  Gets a single distributor.

  Raises `Ecto.NoResultsError` if the Distributor does not exist.

  ## Examples

      iex> get_distributor!(123)
      %Distributor{}

      iex> get_distributor!(456)
      ** (Ecto.NoResultsError)

  """
  def get_distributor!(id), do: Repo.get!(Distributor, id)

  @doc """
  Creates a distributor.

  ## Examples

      iex> create_distributor(%{field: value})
      {:ok, %Distributor{}}

      iex> create_distributor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_distributor(attrs \\ %{}) do
    %Distributor{}
    |> Distributor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a distributor.

  ## Examples

      iex> update_distributor(distributor, %{field: new_value})
      {:ok, %Distributor{}}

      iex> update_distributor(distributor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_distributor(%Distributor{} = distributor, attrs) do
    distributor
    |> Distributor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a distributor.

  ## Examples

      iex> delete_distributor(distributor)
      {:ok, %Distributor{}}

      iex> delete_distributor(distributor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_distributor(%Distributor{} = distributor) do
    Repo.delete(distributor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking distributor changes.

  ## Examples

      iex> change_distributor(distributor)
      %Ecto.Changeset{data: %Distributor{}}

  """
  def change_distributor(%Distributor{} = distributor, attrs \\ %{}) do
    Distributor.changeset(distributor, attrs)
  end
end
