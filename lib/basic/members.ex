defmodule Basic.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Members.Member
  alias Basic.Accounts.User

  @doc """
  Returns the list of members.

  ## Examples

      iex> list_members()
      [%Member{}, ...]

  """
  def list_members, do: paginate_members

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id) do
    users = from user in User
    Repo.all(from member in Member, where: member.id == ^id,
              join: user in ^users,
              on: [id: member.user_id],
              select: %{
                id: member.id,
                user_id: member.user_id,
                last_name: member.last_name,
                last_name_kana: member.last_name_kana,
                first_name: member.first_name,
                first_name_kana: member.first_name_kana,
                image: member.image,
                birthday: member.birthday,
                corporate_id: member.corporate_id,
                corporate_name: member.corporate_name,
                deleted_at: member.deleted_at,
                department: member.department,
                detail: member.detail,
                industry: member.industry,
                position: member.position,
                email: user.email
              }
    )
  end

  def get_delete_member!(id), do: Repo.get!(Member, id)

  @doc """
  Creates a member.

  ## Examples

      iex> create_member(%{field: value})
      {:ok, %Member{}}

      iex> create_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_member(attrs \\ %{}) do
    %Member{}
    |> Member.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a member.

  ## Examples

      iex> update_member(member, %{field: new_value})
      {:ok, %Member{}}

      iex> update_member(member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_member(member, attrs) do
    data = %Member{}
                |> Map.put(:id, member.id)
                |> Map.put(:user_id, member.user_id)
                |> Map.put(:last_name, member.last_name)
                |> Map.put(:last_name_kana, member.last_name_kana)
                |> Map.put(:first_name, member.first_name)
                |> Map.put(:first_name_kana, member.first_name_kana)
                |> Map.put(:image, member.image)
                |> Map.put(:birthday, member.birthday)
                |> Map.put(:corporate_id, member.corporate_id)
                |> Map.put(:corporate_name, member.corporate_name)
                |> Map.put(:deleted_at, member.deleted_at)
                |> Map.put(:department, member.department)
                |> Map.put(:detail, member.detail)
                |> Map.put(:industry, member.industry)
                |> Map.put(:position, member.position)

    data
    |> Member.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a member.

  ## Examples

      iex> delete_member(member)
      {:ok, %Member{}}

      iex> delete_member(member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_member(%Member{} = member) do
    Repo.delete(member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking member changes.

  ## Examples

      iex> change_member(member)
      %Ecto.Changeset{data: %Member{}}

  """
  def change_member(member, attrs \\ %{}) do
    data = %Member{}
            |> Map.put(:id, member.id)
            |> Map.put(:user_id, member.user_id)
            |> Map.put(:last_name, member.last_name)
            |> Map.put(:last_name_kana, member.last_name_kana)
            |> Map.put(:first_name, member.first_name)
            |> Map.put(:first_name_kana, member.first_name_kana)
            |> Map.put(:image, member.image)
            |> Map.put(:birthday, member.birthday)
            |> Map.put(:corporate_id, member.corporate_id)
            |> Map.put(:corporate_name, member.corporate_name)
            |> Map.put(:deleted_at, member.deleted_at)
            |> Map.put(:department, member.department)
            |> Map.put(:detail, member.detail)
            |> Map.put(:industry, member.industry)
            |> Map.put(:position, member.position)
    Member.changeset(data, attrs)
  end

  def paginate_members(page_number \\ 1, search \\ "") do
    users = from user in User
    query = from member in Member,
              join: user in User,
              on: [id: member.user_id],
              select: %{
                id: member.id,
                user_id: member.user_id,
                last_name: member.last_name,
                last_name_kana: member.last_name_kana,
                first_name: member.first_name,
                first_name_kana: member.first_name_kana,
                image: member.image,
                birthday: member.birthday,
                corporate_id: member.corporate_id,
                corporate_name: member.corporate_name,
                deleted_at: member.deleted_at,
                department: member.department,
                detail: member.detail,
                industry: member.industry,
                position: member.position,
                email: user.email
              }

  query = if search != "" do
      from member in query, 
        join: user in User,
        on: [id: member.user_id],
      where: like( member.last_name, ^"%#{ search }%" ) or like( member.first_name, ^"%#{ search }%" ) or like( user.email, ^"%#{ search }%" )
    else
      query
    end

   query
    |> Repo.paginate([page: page_number])
  end
end
