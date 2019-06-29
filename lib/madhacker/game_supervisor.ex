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
    users_nodes_if = Enum.filter(flat_graph, fn node ->
      node.layer == 3
    end)
    users_nodes = Enum.take_random(users_nodes_if, Enum.count(users))
    ziped = Enum.zip(users, users_nodes)

    newgraph = Enum.reduce(Map.values(graph), ziped, fn node, acc ->
      newNode = Map.put(node, :defense, 40 - 10*node.layer)
      servernode = init_server_node(newNode)
      nn = Enum.find(acc, nil, fn { u, n } ->
        n.id == node.id
      end)
      if nn != nil do
        init_user_node(servernode, nn)
      else
        servernode
      end
    end)

    spec = { Madhacker.Game, { game_id, newgraph, users} }
    case DynamicSupervisor.start_child(__MODULE__, spec) do
      { :ok, pid } ->
        Registry.register(@registry, game_id, pid)
        { :ok, game_id }

      other ->
        { :error, other }
    end
  end

  def init_user_node(node, usr) do
       Map.put(
         Map.put(Map.put(node, :attack, 10),
           :type, :user),
       :user, usr)

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
