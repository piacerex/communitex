defmodule CssSwitcher do
  def start_link(data \\ %{current: "", cdns: ""}) do
    case is_alive() do
      false ->
        {:ok, pid} = Agent.start_link(fn -> [0] end, name: :css_switcher)
        :global.register_name(:css_switcher, pid)
        update(data)
        pid

      _ ->
        pid()
    end
  end

  def update(%{current: _, cdns: _} = map), do: Agent.update(:css_switcher, fn _dummy -> map end)

  def current(), do: Agent.get(:css_switcher, & &1.current)
  def cdns(), do: Agent.get(:css_switcher, & &1.cdns)

  def pid(), do: :global.whereis_name(:css_switcher)
  def is_alive(), do: pid() != :undefined
end
