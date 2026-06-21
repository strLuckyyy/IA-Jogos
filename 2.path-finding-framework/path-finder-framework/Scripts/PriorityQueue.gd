class_name PriorityQueue
extends RefCounted

# Armazena os elementos no formato de dicionário: {"item": SearchNode, "priority": float}
var _elements: Array[Dictionary] = []

# Verifica se a fila está vazia
func is_empty() -> bool:
	return _elements.is_empty()

# Insere um item na fila de acordo com sua prioridade (custo)
func put(item: Variant, priority: float) -> void:
	# Otimização Godot: Ordenamos do MAIOR custo para o MENOR custo.
	# Assim, o menor valor sempre fica no final do array, permitindo o uso de
	# pop_back(), que tem complexidade O(1) e não trava o jogo em mapas grandes.
	
	var low: int = 0
	var high: int = _elements.size() - 1
	
	# Busca Binária para encontrar a posição exata de inserção
	while low <= high:
		var mid: int = (low + high) / 2
		
		if _elements[mid].priority == priority:
			low = mid 
			break
		elif _elements[mid].priority < priority:
			# Se o custo do meio é menor, temos que buscar na metade esquerda
			high = mid - 1
		else:
			# Se o custo do meio é maior, temos que buscar na metade direita
			low = mid + 1
			
	var new_entry: Dictionary = {"item": item, "priority": priority}
	_elements.insert(low, new_entry)

# Retira e retorna o item com a MENOR prioridade (menor custo)
func get_item() -> Variant:
	if is_empty():
		return null
		
	var entry = _elements.pop_back()
	return entry.item
