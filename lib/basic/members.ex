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
  def list_members, do: paginate_members()

  @doc """
  Gets a single member.

  Raises `Ecto.NoResultsError` if the Member does not exist.

  ## Examples

      iex> get_member!(123)
      %Member{}

      iex> get_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_member!(id), do: Repo.get!(Member, id)

  def get_member_with_user(id) do
    users = from user in User
    fields = Member.__schema__(:fields)
    Repo.all(
      from(member in Member, 
        where: member.id == ^id,
        join: user in User,
          on: [id: member.user_id],
        select: {map(member, ^fields), map(user, [:email])}
      ) 
    )
    |> Enum.map(& Map.merge(elem(&1, 0), elem(&1, 1)))
    |> List.first
  end

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
#  def update_member(%Member{} = member, attrs) do
  def update_member(member, attrs) do
    attrs = case attrs["image"] do
      nil -> Map.delete(attrs, "image")
      _ -> attrs
    end
  
    member
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
#  def change_member(%Member{} = member, attrs \\ %{}) do
  def change_member(member, attrs \\ %{}) do
    %Member{}
    |> Map.merge(Map.take(member, Map.keys(%Member{})))
    |> Member.changeset(attrs)
  end

  def paginate_members(page \\ 1, search \\ "") do
    fields = Member.__schema__(:fields)
    query = 
      from(member in Member,
        join: user in User, 
          on: [id: member.user_id],
        order_by: [desc: member.id], 
        select: {map(member, ^fields), map(user, [:email])}
      )

    result = case search do
      ""     -> query
      search -> 
        from(member in query, 
          join: user in User,
            on: [id: member.user_id],
        where: like(member.last_name,  ^"%#{search}%") 
            or like(member.first_name, ^"%#{search}%") 
            or like(user.email,        ^"%#{search}%")
        )
    end
    |> Repo.paginate([page: page])

    Map.put(result, :entries, Enum.map(result.entries, & Map.merge(elem(&1, 0), elem(&1, 1))))
  end
end
