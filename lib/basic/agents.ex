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
#  def list_agents do
#    Repo.all(Agent)
#  end
  def list_agents do
    users = from user in User
    agencies = from agency in Agency

    Repo.all(from agent in Agent,
              join: user in ^users,
              on: [id: agent.user_id],
              join: agency in ^agencies,
              on: [id: agent.agency_id],
              select: %{
                id: agent.id,
                user_id: agent.user_id,
                user_email: user.email,
                agency_id: agent.agency_id,
                agency_brand: agency.brand,
                boost: agent.boost,
                discount: agent.discount,
                deleted_at: agent.deleted_at
              }
    )
  end

  def select_agents(user_id, agency_id) do
    relate_agencies = get_relate_agancies(user_id)
    show_agency = if agency_id == "" do
      List.first(relate_agencies).id
    else
      agency_id
    end

    users = from user in User
    agencies = from agency in Agency
    query = from agent in Agent,
            where: agent.agency_id == ^show_agency,
            join: user in ^users,
            on: [id: agent.user_id],
            join: agency in ^agencies,
            on: [id: agent.agency_id],
            select: %{
              id: agent.id,
              user_id: agent.user_id,
              user_email: user.email,
              agency_id: agent.agency_id,
              agency_brand: agency.brand,
              boost: agent.boost,
              discount: agent.discount,
              deleted_at: agent.deleted_at
            }
    agent = Repo.all(query)
  end

  def get_relate_agancies(user_id) do
    grant = List.first(Grants.get_user_grant!(user_id))
    query = from agency in Agency,
            where: agency.corporate_id == ^grant.corporate_id
    relate_agencies = Repo.all(query) 
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
#  def get_agent!(id), do: Repo.get!(Agent, id)
  def get_agent!(id) do
    users = from user in User
    agencies = from agency in Agency

    Repo.all(from agent in Agent,
              where: agent.id == ^id,
              join: user in ^users,
              on: [id: agent.user_id],
              join: agency in ^agencies,
              on: [id: agent.agency_id],
              select: %{
                id: agent.id,
                user_id: agent.user_id,
                user_email: user.email,
                agency_id: agent.agency_id,
                agency_brand: agency.brand,
                boost: agent.boost,
                discount: agent.discount,
                deleted_at: agent.deleted_at
              }
    )
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
#  def update_agent(%Agent{} = agent, attrs) do
#    agent
#    |> Agent.changeset(attrs)
#    |> Repo.update()
#  end
  def update_agent(agent, attrs) do
    data = %Agent{}
            |> Map.put(:id, agent.id)
            |> Map.put(:agency_id, agent.agency_id)
            |> Map.put(:boost, agent.boost)
            |> Map.put(:deleted_at, agent.deleted_at)
            |> Map.put(:discount, agent.discount)
            |> Map.put(:user_id, agent.user_id)

    data
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

#  def delete_agent(%Agent{} = agent) do
#    Repo.delete(agent)
#  end
  def delete_agent(agent) do
    data = %Agent{}
            |> Map.put(:id, agent.id)
            |> Map.put(:agency_id, agent.agency_id)
            |> Map.put(:boost, agent.boost)
            |> Map.put(:deleted_at, agent.deleted_at)
            |> Map.put(:discount, agent.discount)
            |> Map.put(:user_id, agent.user_id)
    
    Repo.delete(data)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking agent changes.

  ## Examples

      iex> change_agent(agent)
      %Ecto.Changeset{data: %Agent{}}

  """
#  def change_agent(%Agent{} = agent, attrs \\ %{}) do
#    Agent.changeset(agent, attrs)
#  end
  def change_agent(agent, attrs \\ %{}) do
    data = %Agent{}
            |> Map.put(:id, agent.id)
            |> Map.put(:agency_id, agent.agency_id)
            |> Map.put(:boost, agent.boost)
            |> Map.put(:deleted_at, agent.deleted_at)
            |> Map.put(:discount, agent.discount)
            |> Map.put(:user_id, agent.user_id)

    Agent.changeset(data, attrs)
  end

  def check_user_id() do
    agents_user = from agent in Agent, select: agent.user_id
    query = from user in User, select: user.id, except_all: ^agents_user
    candidate_user_id = Repo.all(query)
  end

  def search_user(search) do
    candidate_user_id = check_user_id()

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
    |> Enum.filter(&(Enum.member?(candidate_user_id, &1.id)))
    |> Enum.map(fn map -> Enum.reduce([:last_name, :first_name], map, fn key, acc -> Map.put(acc, key, (if is_nil(map[key]), do: "", else: map[key])) end) end)
  end
end
