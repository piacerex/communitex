defmodule Basic.Agencies do
  @moduledoc """
  The Agencies context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Agencies.Agency

  @doc """
  Returns the list of agencies.

  ## Examples

      iex> list_agencies()
      [%Agency{}, ...]

  """
  def list_agencies do
    Repo.all(Agency)
  end

  @doc """
  Gets a single agency.

  Raises `Ecto.NoResultsError` if the Agency does not exist.

  ## Examples

      iex> get_agency!(123)
      %Agency{}

      iex> get_agency!(456)
      ** (Ecto.NoResultsError)

  """
  def get_agency!(id), do: Repo.get!(Agency, id)

  @doc """
  Creates a agency.

  ## Examples

      iex> create_agency(%{field: value})
      {:ok, %Agency{}}

      iex> create_agency(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_agency(attrs \\ %{}) do
    %Agency{}
    |> Agency.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a agency.

  ## Examples

      iex> update_agency(agency, %{field: new_value})
      {:ok, %Agency{}}

      iex> update_agency(agency, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_agency(%Agency{} = agency, attrs) do
    agency
    |> Agency.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a agency.

  ## Examples

      iex> delete_agency(agency)
      {:ok, %Agency{}}

      iex> delete_agency(agency)
      {:error, %Ecto.Changeset{}}

  """
  def delete_agency(%Agency{} = agency) do
    Repo.delete(agency)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agency changes.

  ## Examples

      iex> change_agency(agency)
      %Ecto.Changeset{data: %Agency{}}

  """
  def change_agency(%Agency{} = agency, attrs \\ %{}) do
    Agency.changeset(agency, attrs)
  end

  def get_agency_name(id) do
    from( agency in Agency,
            where: agency.id == ^id,
            select: %{
              id: agency.id,
              brand: agency.brand
            } )
    |> Repo.all
  end
end
