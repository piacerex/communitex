defmodule Basic.Agents do
  @moduledoc """
  The Agents context.
  """

  import Ecto.Query, warn: false
  alias Basic.Repo

  alias Basic.Agents.Agent
  alias Basic.Grants
  alias Basic.Agencies
  alias Basic.Agencies.Agency
  alias Basic.Accounts.User
  alias Basic.Members.Member

  @doc """
  Returns the list of agents.

  ## Examples

      iex> list_agents()
      [%Agent{}, ...]

  """
  def list_agents do
    users = from user in User
    agencies = from agency in Agency
    from( agent in Agent,
          join: user in ^users,
          on: [id: agent.user_id],
          join: agency in ^agencies,
          on: [id: agent.agency_id],
          select: [
            map(agent, ^Agent.__schema__(:fields)),
            map(user, ^User.__schema__(:fields)),
            map(agency, ^Agency.__schema__(:fields))
          ] )
    |> Repo.all
  end

  def get_selected_agents(user_id, agency_id) do
    related_agencies = get_granted_agencies(user_id)
    selected_agency = case agency_id do
      "" -> List.first(related_agencies).id
      _  -> agency_id
    end

    users = from user in User
    agencies = from agency in Agency
    from( agent in Agent,
          where: agent.agency_id == ^selected_agency,
          join: user in ^users,
          on: [id: agent.user_id],
          join: agency in ^agencies,
          on: [id: agent.agency_id],
          select: [
            map(agent, ^Agent.__schema__(:fields)),
            map(user, ^User.__schema__(:fields)),
            map(agency, ^Agency.__schema__(:fields))
          ] )
    |> Repo.all
  end

  def get_granted_agencies(user_id) do
    grants = Grants.get_user_grants!(user_id)
    organization_ids = Enum.sort(Enum.uniq(Enum.map(grants, fn map -> Map.get(map, :organization_id) end)))
    agencies =
      for organization_id <- organization_ids do
        from( agency in Agency, where: agency.organization_id == ^organization_id )
        |> Repo.all
      end
    List.flatten(agencies)
  end

  @doc """
  Gets a single agent.

  Raises `Ecto.NoResultsError` if the Agent does not exist.

  ## Examples

      iex> get_agent!(123)
      %Agent{}

      iex> get_agent!(456)
      ** (Ecto.NoResultsError)

  """
  def get_agent!(id) do
    users = from user in User
    agencies = from agency in Agency

    from( agent in Agent,
          where: agent.id == ^id,
          join: user in ^users,
          on: [id: agent.user_id],
          join: agency in ^agencies,
          on: [id: agent.agency_id],
          select: [
            map(agent, ^Agent.__schema__(:fields)),
            map(user, ^User.__schema__(:fields)),
            map(agency, ^Agency.__schema__(:fields))
          ] )
    |> Repo.all
  end

  @doc """
  Creates a agent.

  ## Examples

      iex> create_agent(%{field: value})
      {:ok, %Agent{}}

      iex> create_agent(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_agent(attrs \\ %{}) do
    %Agent{}
    |> Agent.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a agent.

  ## Examples

      iex> update_agent(agent, %{field: new_value})
      {:ok, %Agent{}}

      iex> update_agent(agent, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_agent(agent, attrs) do
    data = case is_map(agent) do
      true -> agent
      _ -> List.first(agent)
    end

    agent = %Agent{}
            |> Map.put(:id, data.id)
            |> Map.put(:agency_id, data.agency_id)
            |> Map.put(:boost, data.boost)
            |> Map.put(:deleted_at, data.deleted_at)
            |> Map.put(:discount, data.discount)
            |> Map.put(:user_id, data.user_id)

    agent
    |> Agent.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a agent.

  ## Examples

      iex> delete_agent(agent)
      {:ok, %Agent{}}

      iex> delete_agent(agent)
      {:error, %Ecto.Changeset{}}

  """
  def get_delete_agent!(id), do: Repo.get!(Agent, id)

  def delete_agent(agent) do
    agent = %Agent{}
            |> Map.put(:id, agent.id)
            |> Map.put(:agency_id, agent.agency_id)
            |> Map.put(:boost, agent.boost)
            |> Map.put(:deleted_at, agent.deleted_at)
            |> Map.put(:discount, agent.discount)
            |> Map.put(:user_id, agent.user_id)
    
    Repo.delete(agent)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent changes.

  ## Examples

      iex> change_agent(agent)
      %Ecto.Changeset{data: %Agent{}}

  """
  def change_agent(agent, attrs \\ %{}) do
    data = case is_map(agent) do
      true -> agent
      _ -> List.first(agent)
    end

    agent = %Agent{}
            |> Map.put(:id, data.id)
            |> Map.put(:agency_id, data.agency_id)
            |> Map.put(:boost, data.boost)
            |> Map.put(:deleted_at, data.deleted_at)
            |> Map.put(:discount, data.discount)
            |> Map.put(:user_id, data.user_id)

    Agent.changeset(agent, attrs)
  end

  def not_registered_user_ids() do
    agents_user = from agent in Agent, select: agent.user_id
    from( user in User, select: user.id, except_all: ^agents_user )
    |> Repo.all
  end

  def search_users(search) do
    candidate_user_ids = not_registered_user_ids()

    query = 
      from( member in Member,
        right_join: user in User, 
          on: [id: member.user_id],
        where: like(member.last_name,  ^"%#{search}%") 
            or like(member.first_name, ^"%#{search}%") 
            or like(user.email,        ^"%#{search}%"),
        select: 
        %{
          id: user.id,
          email: user.email,
          last_name: member.last_name,
          first_name: member.first_name
        }
      )

    Repo.all(query)
    |> Enum.filter(&(Enum.member?(candidate_user_ids, &1.id)))
    |> Enum.map(fn map -> Enum.reduce([:last_name, :first_name], map, fn key, acc -> Map.put(acc, key, (if is_nil(map[key]), do: "", else: map[key])) end) end)
  end
end
