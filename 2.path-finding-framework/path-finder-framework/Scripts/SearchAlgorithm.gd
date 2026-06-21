class_name SearchAlgorithm
extends RefCounted

var graph: GridGraph
var frontier: Array[SearchNode] = []
var visited: Dictionary = {}
var closed_set: Dictionary = {} # Conjunto de nós já processados
var cancelled: bool = false 

func _init(_graph: GridGraph):
	graph = _graph

func solve(start: Vector2i, goal: Vector2i, tree: SceneTree = null, redraw_callback: Callable = Callable()) -> Array[Vector2i]:
	frontier.clear()
	visited.clear()
	closed_set.clear() # Limpa para o BFS
	cancelled = false
	
	var start_node = SearchNode.new(start)
	_add_to_frontier(start_node)
	visited[start] = start_node
	
	# Loop genérico usado primariamente pelo BFS
	while not frontier.is_empty():
		if cancelled:
			return []
			
		var current_node = _get_from_frontier()
		
		# MARCA O NÓ COMO PROCESSADO! (Isso tira o amarelo e bota o azul)
		closed_set[current_node.cell] = true
		
		if current_node.cell == goal:
			return _reconstruct_path(current_node)
			
		for neighbor in graph.get_neighbors(current_node.cell):
			if not visited.has(neighbor):
				var new_node = SearchNode.new(neighbor, current_node)
				visited[neighbor] = new_node
				_add_to_frontier(new_node)
				
		# Verificação de segurança para não travar a Godot
		if tree != null and redraw_callback.is_valid():
			redraw_callback.call() 
			await tree.create_timer(0.01).timeout 
				
	return []

func _reconstruct_path(node: SearchNode) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	var current = node
	while current != null:
		path.append(current.cell)
		current = current.parent
	path.reverse() 
	return path

func _add_to_frontier(_node: SearchNode):
	assert(false, "Implementar _add_to_frontier na filha!")

func _get_from_frontier() -> SearchNode:
	assert(false, "Implementar _get_from_frontier na filha!")
	return null
