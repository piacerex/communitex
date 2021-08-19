defmodule Basic.Grants do
  @moduledoc """
  The Grants context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Grants.Grant

  @doc """
  Returns the list of grants.

  ## Examples

      iex> list_grants()
      [%Grant{}, ...]

  """
  def list_grants do
    Repo.all(Grant)
  end

  @doc """
  Gets a single grant.

  Raises `Ecto.NoResultsError` if the Grant does not exist.

  ## Examples

      iex> get_grant!(123)
      %Grant{}

      iex> get_grant!(456)
      ** (Ecto.NoResultsError)

  """
  def get_grant!(id), do: Repo.get!(Grant, id)

  def get_user_grant!(user_id) do
    query = from grant in Grant,
            where: grant.user_id == ^user_id
    Repo.all(query)
  end

  @doc """
  Creates a grant.

  ## Examples

      iex> create_grant(%{field: value})
      {:ok, %Grant{}}

      iex> create_grant(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_grant(attrs \\ %{}) do
    %Grant{}
    |> Grant.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a grant.

  ## Examples

      iex> update_grant(grant, %{field: new_value})
      {:ok, %Grant{}}

      iex> update_grant(grant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grant(%Grant{} = grant, attrs) do
    grant
    |> Grant.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a grant.

  ## Examples

      iex> delete_grant(grant)
      {:ok, %Grant{}}

      iex> delete_grant(grant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grant(%Grant{} = grant) do
    Repo.delete(grant)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grant changes.

  ## Examples

      iex> change_grant(grant)
      %Ecto.Changeset{data: %Grant{}}

  """
  def change_grant(%Grant{} = grant, attrs \\ %{}) do
    Grant.changeset(grant, attrs)
  end
end
