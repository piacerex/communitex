defmodule ContentFolder do
  def start_link(data \\ "") do
    case is_alive() do
      false -> 
        {:ok, pid} = Agent.start_link(fn -> [0] end, name: :content_folder)
        :global.register_name(:content_folder, pid)
        update(data)
        pid
      _ -> pid()
    end
  end

  def update(data), do: Agent.update(:content_folder, fn _dummy -> data end)
  def get(), do: Agent.get(:content_folder, & &1)

  def pid(), do: :global.whereis_name(:content_folder)
  def is_alive(), do: pid() != :undefined
end
