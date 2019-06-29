defmodule Madhacker.MatchMaker do
  use GenServer

  def init(state), do: {:ok, state}

  def handle_cast({:join, user_id}, []) do
    {:noreply, [user_id]}
  end

  def handle_cast({:join, user_id}, [another]) do
    if user_id != another do
      MadhackerWeb.Endpoint.broadcast("user:#{ user_id }", "game:started", %{ "another" => another})
      MadhackerWeb.Endpoint.broadcast("user:#{ another }", "game:started", %{ "another" => user_id})
      {:noreply, []}
    end
    {:noreply, [another]}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def join(user_id), do: GenServer.cast(__MODULE__, {:join, user_id})
end
