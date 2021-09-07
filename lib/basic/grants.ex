defmodule Basic.Grants do
  @moduledoc """
  The Grants context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Grants.Grant
  alias Basic.Organizations.Organization
  alias Basic.Accounts.User
  alias Basic.Members.Member

  @doc """
  Returns the list of grants.

  ## Examples

      iex> list_grants()
      [%Grant{}, ...]

  """
  def list_grants do
    organizations = from organization in Organization
    users = from user in User
    from( grant in Grant,
      join: user in ^users,
      on: [id: grant.user_id],
      join: organization in ^organizations,
      on: [id: grant.organization_id],
      select: [
        map(grant, ^Grant.__schema__(:fields)),
        map(user, ^User.__schema__(:fields)),
        map(organization, ^Organization.__schema__(:fields))
      ] )
    |> Repo.all
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
  def get_grant!(id) do
    organizations = from organization in Organization
    users = from user in User
    from( grant in Grant,
      where: grant.id == ^id,
      join: user in ^users,
      on: [id: grant.user_id],
      join: organization in ^organizations,
      on: [id: grant.organization_id],
      select: [
        map(grant, ^Grant.__schema__(:fields)),
        map(user, ^User.__schema__(:fields)),
        map(organization, ^Organization.__schema__(:fields))
      ] )
    |> Repo.all
    |> List.first
  end

  def get_user_grants!(user_id) do
    from( grant in Grant,
      where: grant.user_id == ^user_id)
    |> Repo.all
  end

  def find_user_grants!(user_id, roles) do
    from( grant in Grant,
      where: grant.user_id == ^user_id
        and grant.role in ^roles)
    |> Repo.all
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

  def check_grant(data) do
    from( grant in Grant,
      where: grant.user_id == ^data["user_id"] and
      grant.organization_id == ^data["organization_id"] and
      grant.role == ^data["role"])
    |> Repo.all
  end

  @doc """
  Updates a grant.

  ## Examples

      iex> update_grant(grant, %{field: new_value})
      {:ok, %Grant{}}

      iex> update_grant(grant, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_grant(grant, attrs) do
    %Grant{}
    |> Map.put(:id, grant.id)
    |> Map.put(:user_id, grant.user_id)
    |> Map.put(:organization_id, grant.organization_id)
    |> Map.put(:role, grant.role)
    |> Map.put(:deleted_at, grant.deleted_at)
    |> Grant.changeset(attrs)
    |> Repo.update
  end

  @doc """
  Deletes a grant.

  ## Examples

      iex> delete_grant(grant)
      {:ok, %Grant{}}

      iex> delete_grant(grant)
      {:error, %Ecto.Changeset{}}

  """
  def delete_grant(grant) do
    %Grant{}
    |> Map.put(:id, grant.id)
    |> Map.put(:user_id, grant.user_id)
    |> Map.put(:organization_id, grant.organization_id)
    |> Map.put(:role, grant.role)
    |> Map.put(:deleted_at, grant.deleted_at)
    |> Repo.delete
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking grant changes.

  ## Examples

      iex> change_grant(grant)
      %Ecto.Changeset{data: %Grant{}}

  """
  def change_grant(grant, attrs \\ %{}) do
    %Grant{}
    |> Map.put(:id, grant.id)
    |> Map.put(:user_id, grant.user_id)
    |> Map.put(:organization_id, grant.organization_id)
    |> Map.put(:role, grant.role)
    |> Map.put(:deleted_at, grant.deleted_at)
    |> Grant.changeset(attrs)
  end

  def get_role_list(current_user_id) do
    roles = from( grant in Grant,
        where: grant.user_id == ^current_user_id,
        select: grant.role)
      |> Repo.all

    cond do
      Enum.member?(roles, system_admin().name)       -> roles()
      Enum.member?(roles, organization_admin().name) -> [organization_admin()]
      Enum.member?(roles, distributor_admin().name)  -> [distributor_admin()]
      Enum.member?(roles, agency_admin().name)       -> [agency_admin()]
      true -> []
    end
  end

  def system_admin(), do: %{name: "SystemAdmin", display: "システム管理者"}
  def distributor_admin(), do: %{name: "DistributorAdmin", display: "卸者管理者"}
  def agency_admin(), do: %{name: "AgencyAdmin", display: "代理店管理者"}
  def organization_admin(), do: %{name: "OrganizationAdmin", display: "組織管理者"}
  def roles() do
    [
      system_admin(),
      organization_admin(),
      distributor_admin(),
      agency_admin(),
      content_editor(),
    ]
  end
  def content_editor(), do: %{name: "ContentEditor", display: "コンテンツ編集者"}

  def search_user(search) do
    members = from member in Member
    from(user in User,
      left_join: member in ^members,
      on: [user_id: user.id],
      where: like(member.last_name, ^"%#{search}%")
        or like(member.first_name, ^"%#{search}%")
        or like(user.email, ^"%#{search}%"),
      select: %{user_id: user.id,
        email: user.email,
        last_name: member.last_name,
        first_name: member.first_name
      }
    )
    |> Repo.all
    |> Enum.map(fn map -> Enum.reduce([:last_name, :first_name], map, fn key, acc -> Map.put(acc, key, (if is_nil(map[key]), do: "", else: map[key])) end) end)
  end
end
