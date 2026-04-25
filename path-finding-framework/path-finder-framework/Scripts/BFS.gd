class_name BFS
extends SearchAlgorithm

# No BFS (Fila), quem chega entra no final da fila.
func _add_to_frontier(node: SearchNode):
	frontier.push_back(node)

# No BFS (Fila), quem é atendido é o primeiro que chegou.
func _get_from_frontier() -> SearchNode:
	return frontier.pop_front()
