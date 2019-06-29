defmodule Madhacker.MatchMaker do
  use GenServer

  require Logger

  def init(state), do: {:ok, state}

  def handle_cast({:join, user_id}, []) do
    {:noreply, [user_id]}
  end

  def handle_cast({:join, user_id}, [user_id]) do
    {:noreply, [user_id]}
  end

  def handle_cast({:join, user_id}, [another]) do
    Logger.debug("generate graph for user #{ user_id } and #{ another }")

    graph = Madhacker.Graph.generate(3, 3, 3)
    Logger.debug("Graph for user #{ user_id } and #{ another } DONE!")

    Madhacker.GameSupervisor.start_child(graph, [user_id, another])
    Logger.debug("Started childs for user #{ user_id } and #{ another }")

    # MadhackerWeb.Endpoint.broadcast("user:#{ user_id }", "game:started", %{ another: another })
    # Logger.debug("Send game:started to #{ user_id }")
    # MadhackerWeb.Endpoint.broadcast("user:#{ another }", "game:started", %{ another: user_id })
    # Logger.debug("Send game:started to #{ another }")

    {:noreply, []}
  end

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def join(user_id), do: GenServer.cast(__MODULE__, {:join, user_id})
end
