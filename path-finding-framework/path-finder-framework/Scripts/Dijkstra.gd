class_name Dijkstra
extends SearchAlgorithm

var pq: PriorityQueue = PriorityQueue.new()

func solve(start: Vector2i, goal: Vector2i, tree: SceneTree = null, redraw_callback: Callable = Callable()) -> Array[Vector2i]:
	frontier.clear()
	visited.clear()
	closed_set.clear()
	pq = PriorityQueue.new() 
	cancelled = false
	
	# Nó inicial tem custo G = 0
	var start_node = SearchNode.new(start, null, 0.0)
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
			
			# TODO 1: Qual é o custo para dar este passo? (Assuma 1.0 por enquanto)
			var step_cost = 1.0 # Substitua 0.0 pela lógica correta
			
			# TODO 2: Como calculamos o novo custo acumulado (G)?
			var new_g_cost = step_cost + current_node.g_cost # Substitua 0.0 pela lógica correta
			
			# TODO 3: Qual é a condição dupla para explorar este vizinho no Dijkstra?
			# Dica: Ou ele é inédito, ou achamos um caminho MAIS BARATO para ele!
						
			if not visited.has(neighbor) or new_g_cost < visited[neighbor].g_cost:
				var new_node = SearchNode.new(neighbor, current_node, new_g_cost)
				visited[neighbor] = new_node
				_add_to_frontier(new_node)
				
		if tree != null and redraw_callback.is_valid():
			redraw_callback.call() 
			await tree.create_timer(0.01).timeout 
				
	return []

func _add_to_frontier(node: SearchNode):
	# TODO 4: Qual atributo do 'node' define a prioridade no Dijkstra?
	pq.put(node, node.g_cost)
	pass

func _get_from_frontier() -> SearchNode:
	return pq.get_item()
