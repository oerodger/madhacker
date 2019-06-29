defmodule Madhacker.Graph do
  require Logger
  def generate(core_weight, layer_number, layer_branching) do
    core = Enum.reduce(1..core_weight, %{}, fn x, acc ->
      Map.put(acc, x, %{
        id: x,
        layer: 0,
        neighbors: Enum.filter(1..core_weight, fn y -> x != y end),
      })
    end)
    if layer_number > 0 do
      addLayers(core, layer_number, layer_branching)
    else
      core
    end
  end

  defp addLayers(graph, n, branching) do
    addLayers(graph, 1, n, branching, Map.keys(graph))
  end

  defp addLayers(graph, current, total, _branching, _prev) when current > total do
    graph
  end

  defp addLayers(graph, current, total, branching, prev) do
    { result, next } = addLayer(graph, current, branching, prev)
    addLayers(result, current + 1, total, branching, next)
  end

  defp addLayer(graph, layer, branching, prev) do
    n = Map.size(graph)
    { next, k } = Enum.reduce(prev, {[], n}, fn x, { nodes, total } ->
      { new, d } = newNodes(x, total, layer, branching)
      { nodes ++ new, total + d }
    end)
    wave = Enum.map(next, fn x ->
      cond do
        x.id == k -> %{ x | neighbors: [ n + 1 | [x.id - 1 | x.neighbors ]]}
        x.id == n + 1 -> %{ x | neighbors: [ x.id + 1 | [k | x.neighbors ]]}
        true -> %{ x | neighbors: [ x.id + 1 | [x.id - 1 | x.neighbors ]]}
      end
    end)
    {
      Enum.reduce(wave, graph, fn x, acc -> addNodeToGraph(acc, x, n) end),
      Enum.map(next, fn x -> x.id end)
    }
  end

  defp newNodes(parent, n, layer, branching) do
    k = Enum.random(1..branching)
    nodes = Enum.map(1..k, fn x -> %{
      id: n + x,
      layer: layer,
      neighbors: [parent],
    } end)
    { nodes, k }
  end

  defp addNodeToGraph(graph, node, limit) do
    Enum.reduce(
      Enum.reduce(node.neighbors, [], fn x, acc ->
        if x > limit do
          acc
        else
          [ graph[x] | acc ]
        end
      end),
      Map.put(graph, node.id, node),
      fn x, acc -> %{ acc | x.id => %{ x | neighbors: [ node.id | x.neighbors ] } } end
    )
  end
end
