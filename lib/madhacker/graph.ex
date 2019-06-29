defmodule Madhacker.Graph do
  def generate(core_weight, layer_number, layer_branching) do
    core = Enum.reduce(1..core_weight, %{}, fn x, acc ->
      Map.put(acc, x, %{
        id: x,
        layer: :core,
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
    { next, _ } = Enum.reduce(prev, {[], Map.size(graph)}, fn x, { nodes, n } ->
      { new, k } = newNodes(x, n, layer, branching)
      { nodes ++ new, n + k }
    end)
    {
      Enum.reduce(next, graph, fn x, acc -> addNodeToGraph(acc, x) end),
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

  defp addNodeToGraph(graph, node) do
    Enum.reduce(
      Enum.map(node.neighbors, fn x -> graph[x] end),
      Map.put(graph, node.id, node),
      fn x, acc -> %{ acc | x.id => %{ x | neighbors: x.neighbors ++ [ node.id ] } } end
    )
  end
end
