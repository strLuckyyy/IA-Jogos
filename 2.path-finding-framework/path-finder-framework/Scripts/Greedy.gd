class_name Greedy
extends SearchAlgorithm

var pq: PriorityQueue = PriorityQueue.new()

# Função Heurística
func heuristic(a: Vector2i, b: Vector2i) -> float:
	# TODO 1: Implementar o cálculo da Distância Manhattan
	return abs(a.x - b.x) + abs(a.y - b.y)

func solve(start: Vector2i, goal: Vector2i, tree: SceneTree = null, redraw_callback: Callable = Callable()) -> Array[Vector2i]:
	frontier.clear()
	visited.clear()
	closed_set.clear()
	pq = PriorityQueue.new()
	cancelled = false
	
	var start_node = SearchNode.new(start, null, 0.0)
	# TODO 2: O nó inicial já precisa ter o h_cost calculado!
	start_node.h_cost = heuristic(start, goal)
	
	_add_to_frontier(start_node)

	visited[start] = start_node
	
	while not pq.is_empty():
		if cancelled:
			return []
			
		var current_node = _get_from_frontier()
		
		# Marca o nó como totalmente avaliado!
		closed_set[current_node.cell] = true
		
		if current_node.cell == goal:
			return _reconstruct_path(current_node)
			
		for neighbor in graph.get_neighbors(current_node.cell):
			
			# Na Busca Gulosa, não olhamos para trás. O G_Cost não importa.
			# Só queremos saber se já visitamos essa célula ou não.
			if not visited.has(neighbor):
				
				# Cria o nó (o g_cost pode ficar 0)
				var new_node = SearchNode.new(neighbor, current_node, 0.0)
				
				# TODO 3: Calcule o h_cost deste novo nó usando a heurística!
				new_node.h_cost = heuristic (neighbor, goal)

				visited[neighbor] = new_node
				_add_to_frontier(new_node)
				
		if tree != null and redraw_callback.is_valid():
			redraw_callback.call() 
			await tree.create_timer(0.01).timeout 
				
	return []

func _add_to_frontier(node: SearchNode):
	# TODO 4: Qual atributo do 'node' define a prioridade na Busca Gulosa?
	pq.put(node, node.h_cost)
	pass

func _get_from_frontier() -> SearchNode:
	return pq.get_item()
