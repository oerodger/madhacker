defmodule Madhacker.Game do
  use DynamicSupervisor

  require Logger

  @registry Registry.Actors

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init({ game_id, graph, users }) do
    Logger.info("game starting")
    { _, lksd } = DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [graph]
    )
    Logger.info("copypaste")
    IO.inspect graph
    Enum.each(
      Map.values(graph),
      fn node ->
        case node.type do
          :user -> initUserNode(game_id, node)
          _ -> initServerNode(game_id, node)
        end
      end
    )
    Logger.info("game started")
    Enum.each(users, fn user ->
      MadhackerWeb.Endpoint.broadcast("user:#{ user }", "game:started", %{ id: game_id })
    end)
    { :ok, lksd }
  end

  defp initUserNode(game_id, node) do
    Logger.info("start user actor")
    spec = { Madhacker.UserActor, { self(), node } }
    case DynamicSupervisor.start_child(__MODULE__, spec) do
      { :ok, pid } ->
        Registry.register(@registry, game_id <> node.user, pid)
        Registry.register(@registry, "user:" <> node.id, pid)
        { :ok }

      other ->
        { :error, other }
    end
  end

  defp initServerNode(game_id, node) do
    Logger.info("start server actor")
    spec = { Madhacker.ServerActor, { self(), node } }
    case DynamicSupervisor.start_child(__MODULE__, spec) do
      { :ok, pid } ->
        Registry.register(@registry, game_id <> node.id, pid)
        { :ok }

      other ->
        { :error, other }
    end
  end

  def handle_call({ :user, user_id }, msg, { game_id, graph }) do
    case Registry.lookup(@registry, "user:" <> user_id) do
      [{ pid, _ }] -> send(pid, msg)
    end
    { game_id, graph }
  end

  def handle_cast({ :node, node_id }, msg, { game_id, graph }) do
    case Registry.lookup(@registry, game_id <> node_id) do
      [{ pid, _ }] -> send(pid, msg)
    end
    { game_id, graph }
  end
end
