defmodule ContentFolder do
  def start_link() do
    case is_alive() do
      :undefined -> 
        {:ok, pid} = Agent.start_link(fn -> [0] end, name: :content_folder)
        :global.register_name(:content_folder, pid)
        pid
      pid -> pid
    end
  end

  def update(n) do
    Agent.update(:content_folder, fn _dummy -> n end)
  end

  def get() do
    Agent.get(:content_folder, &(&1))
  end

  def is_alive() do
    :global.whereis_name(:content_folder)
  end
end
