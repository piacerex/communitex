defmodule JsSwitcher do
  def start_link() do
    case is_alive() do
      :undefined -> 
        {:ok, pid} = Agent.start_link(fn -> [0] end)
        :global.register_name(:js_switcher, pid)
        update(%{current: "", cdns: ""})
        pid
      pid -> pid
    end
  end

  def update(%{current: _, cdns: _} = map), do: Agent.update(:js_switcher, fn _dummy -> map end)

  def current(), do: Agent.get(:js_switcher, & &1.current)
  def cdns(),  do: Agent.get(:js_switcher, & &1.cdns)

  def is_alive(), do: :global.whereis_name(:js_switcher) != :undefined
end
