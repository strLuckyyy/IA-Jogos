class_name AStar
extends SearchAlgorithm

var pq: PriorityQueue = PriorityQueue.new()

# Função Heurística
func heuristic(a: Vector2i, b: Vector2i) -> float:
	# TODO 1: Implementar a Distância Manhattan (igual ao da Busca Gulosa)
	return abs(a.x - b.x) + abs(a.y - b.y)

func solve(start: Vector2i, goal: Vector2i, tree: SceneTree = null, redraw_callback: Callable = Callable()) -> Array[Vector2i]:
	frontier.clear()
	visited.clear()
	closed_set.clear() # Limpa os nós já processados
	pq = PriorityQueue.new()
	cancelled = false
	
	var start_node = SearchNode.new(start, null, 0.0)
	# TODO 2: O nó inicial também precisa ter o h_cost calculado!
	start_node.h_cost = heuristic(start,goal)
	
	_add_to_frontier(start_node)
	visited[start] = start_node
	
	while not pq.is_empty():
		if cancelled:
			return []
			
		var current_node = _get_from_frontier()
		
		# Marca o nó como totalmente avaliado (para pintar de azul!)
		closed_set[current_node.cell] = true 
		
		if current_node.cell == goal:
			return _reconstruct_path(current_node)
			
		for neighbor in graph.get_neighbors(current_node.cell):
			
			# TODO 3: Qual é o custo para dar este passo? E qual o novo Custo Acumulado (G)?
			# Dica: Igual ao do Dijkstra!
			var step_cost = 1.0
			var new_g_cost = current_node.g_cost + step_cost
			
			# TODO 4: Qual a condição para o A* explorar este vizinho?
			# Dica: Ou ele é inédito, ou achamos um caminho MAIS BARATO para ele (Igual ao Dijkstra).
						
			if not visited.has(neighbor) or new_g_cost < visited[neighbor].g_cost:
				var new_node = SearchNode.new(neighbor, current_node, new_g_cost)
				
				# TODO 5: Calcule a estimativa (h_cost) deste novo nó para o alvo!
				new_node.h_cost = heuristic(neighbor,goal)
				visited[neighbor] = new_node
				_add_to_frontier(new_node)
				
		if tree != null and redraw_callback.is_valid():
			redraw_callback.call() 
			await tree.create_timer(0.01).timeout 
				
	return []

func _add_to_frontier(node: SearchNode):
	# TODO 6: Qual atributo define a prioridade no A*? 
	# Dica: O A* soma G + H. O 'SearchNode' já tem uma função pronta que retorna essa soma!
	pq.put(node, node.g_cost + node.h_cost)
	pass

func _get_from_frontier() -> SearchNode:
	return pq.get_item()
