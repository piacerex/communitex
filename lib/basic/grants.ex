defmodule Basic.Grants do
  @moduledoc """
  The Grants context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Grants.Grant
  alias Basic.Organizations.Organization
  alias Basic.Organizations
  alias Basic.Accounts.User
  alias Basic.Members.Member

  @doc """
  Returns the list of grants.

  ## Examples

      iex> list_grants()
      [%Grant{}, ...]

  """
  def list_grants(user_id) do
    user_roles = get_user_all_roles(user_id)
    cond do
      Enum.member?(user_roles, system_admin().name) -> list_grants_for_system_admin()
      Enum.empty?(user_roles) -> []
      true -> list_grants_except_system_admin(user_id)
    end
  end

  def list_grants do
    organizations = from organization in Organization
    users = from user in User
    from( grant in Grant,
      order_by: grant.user_id,
      order_by: grant.organization_id,
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

  def list_grants_for_system_admin do
    organizations = from organization in Organization
    users = from user in User
    from( grant in Grant,
      order_by: grant.user_id,
      order_by: grant.organization_id,
      where: grant.role != ^system_admin().name,
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

  def list_grants_except_system_admin(user_id) do
    grants_list = list_grants_for_organization_admin(user_id)
                  ++ list_grants_by_role(user_id, distributor_admin().name)
                  ++ list_grants_by_role(user_id, agency_admin().name)
                  ++ list_grants_by_role(user_id, content_editor().name)
    Enum.sort(Enum.uniq_by(grants_list, fn list -> Enum.at(list, 0).id end), fn(x, y) -> List.first(x).user_id < List.first(y).user_id end)
  end

  def list_grants_for_organization_admin(user_id) do
    query = from grant in Grant,
            where: grant.user_id == ^user_id
               and grant.role == ^organization_admin().name,
            select: grant.organization_id
    granted_organizations = Repo.all(query)
    organizations = from organization in Organization
    users = from user in User

    from( grant in Grant,
      where: grant.organization_id in ^granted_organizations
         and grant.role in ^[organization_admin().name, distributor_admin().name, agency_admin().name],
      order_by: grant.user_id,
      order_by: grant.organization_id,
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
    |> Enum.reject(fn x -> x == [] end)
  end

  def list_grants_by_role(user_id, role) do
    query = from grant in Grant,
            where: grant.user_id == ^user_id
               and grant.role == ^role,
            select: grant.organization_id
    granted_organizations = Repo.all(query)

    organizations = from organization in Organization
    users = from user in User
    from( grant in Grant,
      where: grant.organization_id in ^granted_organizations
          and grant.role == ^role,
      order_by: grant.user_id,
      order_by: grant.organization_id,
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
    |> Enum.reject(fn x -> x == [] end)
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
      order_by: grant.user_id,
      order_by: grant.organization_id,
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

  def is_registered(params) do
    from( grant in Grant,
      where: grant.user_id == ^params["user_id"] and
      grant.organization_id == ^params["organization_id"] and
      grant.role == ^params["role"])
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

  def get_role_list(current_user_id, organization_id) do
    roles = get_user_roles(current_user_id, organization_id)

    cond do
      Enum.member?(roles, system_admin().name)       -> [organization_admin(), distributor_admin(), agency_admin(), content_editor()]
      Enum.member?(roles, organization_admin().name) -> [organization_admin(), distributor_admin(), agency_admin()]
      Enum.member?(roles, distributor_admin().name)  -> [distributor_admin()]
      Enum.member?(roles, agency_admin().name)       -> [agency_admin()]
      Enum.member?(roles, content_editor().name)     -> [content_editor()]
      true -> []
    end
  end

  def get_user_roles(user_id, organization_id) do
    user_roles = get_user_all_roles(user_id)

    cond do
      Enum.member?(user_roles, system_admin().name) -> [system_admin().name]
      true -> 
        from( grant in Grant,
              where: grant.user_id == ^user_id and grant.organization_id == ^organization_id,
              select: grant.role)
        |> Repo.all
    end
  end

  def get_user_all_roles(user_id) do
    from( grant in Grant,
      where: grant.user_id == ^user_id,
      select: grant.role)
    |> Repo.all
  end

  def get_user_roles_for_validate(user_id, organization_id) do
    from( grant in Grant,
      where: grant.user_id == ^user_id and grant.organization_id == ^organization_id,
      select: grant.role)
    |> Repo.all
  end

  def is_editor(user_id) do
    roles = from( grant in Grant,
      where: grant.user_id == ^user_id,
      select: grant.role)
    |> Repo.all

    cond do
      Enum.empty?(roles) -> false
      Enum.member?(roles, content_editor().name) -> true
      true -> false
    end
  end

  def get_grant_id(params) do
    from( grant in Grant,
      where: grant.user_id == ^params["user_id"]
         and grant.organization_id == ^params["organization_id"])
    |> Repo.all
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
      content_editor()
    ]
  end
  def content_editor(), do: %{name: "ContentEditor", display: "コンテンツ編集者"}

  def search_user(search) do
    all_user_ids = Repo.all(from( user in User, select: user.id))
    query = from grant in Grant,
            where: grant.role == ^system_admin().name,
            select: grant.user_id
    system_admin_user_ids = Enum.sort(Enum.uniq(Repo.all(query)))
    registrable_user_ids = all_user_ids -- system_admin_user_ids

    members = from member in Member
    from(user in User,
      left_join: member in ^members,
      on: [user_id: user.id],
      where: like(member.last_name, ^"%#{search}%")
        or like(member.first_name, ^"%#{search}%")
        or like(user.email, ^"%#{search}%")
        and user.id in ^registrable_user_ids,
      select: %{user_id: user.id,
        email: user.email,
        last_name: member.last_name,
        first_name: member.first_name
      }
    )
    |> Repo.all
    |> Enum.map(fn map -> Enum.reduce([:last_name, :first_name], map, fn key, acc -> Map.put(acc, key, (if is_nil(map[key]), do: "", else: map[key])) end) end)
  end

  def get_registrable_organizations(user_id) do
    roles = get_user_all_roles(user_id)

    cond do
      Enum.member?(roles, system_admin().name) -> Organizations.list_organizations()
      Enum.empty?(roles) -> []
      true -> get_granted_organizations(user_id)
    end
  end

  def get_granted_organizations(user_id) do
    organization_ids = get_granted_organization_ids(user_id)

    organizations =
      for organization_id <- organization_ids do
        from( organization in Organization, where: organization.id == ^organization_id )
        |> Repo.all
      end
    List.flatten(organizations)
  end

  def get_granted_organization_ids(user_id) do
    query = from grant in Grant,
            where: grant.user_id == ^user_id,
            select: grant.organization_id
    Enum.sort(Enum.uniq(Repo.all(query)))
  end
end
