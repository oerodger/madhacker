defmodule Madhacker.GameSupervisor do
  use DynamicSupervisor

  @registry Registry.Games

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(graph, _users) do
    game_id = UUID.uuid1()
    # TODO: инициализировать граф, заполнить характеристики
    spec = { Madhacker.Game, { game_id, graph} }
    case DynamicSupervisor.start_child(__MODULE__, spec) do
      { :ok, pid } ->
        Registry.register(@registry, game_id, pid)
        { :ok, game_id }

      other ->
        { :error, other }
    end
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end

  def handle(game_id, node_id, msg) do
    case Registry.lookup(@registry, game_id) do
      [{pid, _}] ->
        send(pid, { node_id, msg })
      other ->
        { :error, other}
    end
  end
end
