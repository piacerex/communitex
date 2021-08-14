defmodule Basic.Corporates do
  @moduledoc """
  The Corporates context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Corporates.Corporate

  @doc """
  Returns the list of corporates.

  ## Examples

      iex> list_corporates()
      [%Corporate{}, ...]

  """
  def list_corporates do
    Repo.all(Corporate)
  end

  @doc """
  Gets a single corporate.

  Raises `Ecto.NoResultsError` if the Corporate does not exist.

  ## Examples

      iex> get_corporate!(123)
      %Corporate{}

      iex> get_corporate!(456)
      ** (Ecto.NoResultsError)

  """
  def get_corporate!(id), do: Repo.get!(Corporate, id)

  @doc """
  Creates a corporate.

  ## Examples

      iex> create_corporate(%{field: value})
      {:ok, %Corporate{}}

      iex> create_corporate(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_corporate(attrs \\ %{}) do
    %Corporate{}
    |> Corporate.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a corporate.

  ## Examples

      iex> update_corporate(corporate, %{field: new_value})
      {:ok, %Corporate{}}

      iex> update_corporate(corporate, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_corporate(%Corporate{} = corporate, attrs) do
    corporate
    |> Corporate.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a corporate.

  ## Examples

      iex> delete_corporate(corporate)
      {:ok, %Corporate{}}

      iex> delete_corporate(corporate)
      {:error, %Ecto.Changeset{}}

  """
  def delete_corporate(%Corporate{} = corporate) do
    Repo.delete(corporate)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking corporate changes.

  ## Examples

      iex> change_corporate(corporate)
      %Ecto.Changeset{data: %Corporate{}}

  """
  def change_corporate(%Corporate{} = corporate, attrs \\ %{}) do
    Corporate.changeset(corporate, attrs)
  end
end
