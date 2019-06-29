defmodule Madhacker.GameSupervisor do
  use DynamicSupervisor

  @registry Registry.Games

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def start_child(graph, users) do
    game_id = UUID.uuid1()
    # TODO: инициализировать граф, заполнить характеристики

    flat_graph = Map.values(graph)
    Enum.each(flat_graph,
      fn node ->
        case node.layer do
          3 -> Map.put(node, :defense, 10)
          2 -> Map.put(node, :defense, 20)
          1 -> Map.put(node, :defense, 30)
          0 -> Map.put(node, :defense, 40)
          _ -> 0
        end
        init_server_node(node)
    end)
    users_nodes_if = Enum.filter(flat_graph, fn node ->
      node.layer == 3
    end)
    users_nodes = Enum.take_random(users_nodes_if, Enum.count(users))
    ziped = Enum.zip(users, users_nodes)

    Enum.each(ziped, fn { user, node } ->
      init_user_node(node, user)
    end)

    spec = { Madhacker.Game, { game_id, graph, users} }
    case DynamicSupervisor.start_child(__MODULE__, spec) do
      { :ok, pid } ->
        Registry.register(@registry, game_id, pid)
        { :ok, game_id }

      other ->
        { :error, other }
    end
  end

  def init_user_node(node, user) do
      Map.put(node, :user, user)
      Map.put(node, :type, :user)
      Map.put(node, :attack, 10)
  end

  def init_server_node(node) do
    Map.put(node, :type, :server)
  end

  @impl true
  def init(init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: [init_arg]
    )
  end

  def send(game_id, user_id, msg) do
    case Registry.lookup(@registry, game_id) do
      [{pid, _}] ->
        send(pid, { { :user, user_id }, msg })
      other ->
        { :error, other}
    end
  end
end
