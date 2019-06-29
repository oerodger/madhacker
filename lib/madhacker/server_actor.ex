defmodule Madhacker.ServerActor do
  use GenServer

  def init(state), do: {:ok, state}

  def handle_call(:attack, val, { node }) do
    if val > node.defence do
      {:hacked}
    else
      {:nothacked}
  end


  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end
end
