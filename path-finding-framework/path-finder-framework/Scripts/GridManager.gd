extends Node2D

@export var rows: int = 25
@export var cols: int = 40
@export var tile_size: int = 20

var color_walkable = Color("#e8e8e8")
var color_walkable_line = Color("#f8f8f8")
var color_wall = Color("#555555")
var color_wall_line = Color("#888888")
var color_start = Color("#ff4444")
var color_goal = Color("#4444ff")

var color_explored = Color("#add8e6", 0.6) # Azul claro (Nós já processados)
var color_frontier = Color("#ffff99", 0.6) # Amarelo claro (Fronteira)
var color_path = Color("#ffd700")          

var start_pos: Vector2i = Vector2i(0, 13)
var goal_pos: Vector2i = Vector2i(11, 1)
var walls: Dictionary = {}

var path: Array[Vector2i] = []
var explored: Dictionary = {}

var is_drawing_walls: bool = true 
var current_search: SearchAlgorithm = null 

# --- NOVA LÓGICA DE SELEÇÃO DE ALGORITMO ---
enum AlgoType { BFS, DIJKSTRA, GREEDY, ASTAR }
var selected_algorithm: AlgoType = AlgoType.BFS
# -------------------------------------------

func _ready():
	# Começamos com a tela limpa.
	queue_redraw()

func _draw():
	for r in range(rows):
		for c in range(cols):
			var rect = Rect2(c * tile_size, r * tile_size, tile_size, tile_size)
			var current_cell = Vector2i(c, r)
			
			var fill_color = color_walkable
			var line_color = color_walkable_line
			
			if walls.has(current_cell):
				fill_color = color_wall
				line_color = color_wall_line
				
			# Verifica primeiro se o nó já foi totalmente processado (Closed Set)
			elif current_search != null and current_search.closed_set.has(current_cell) and current_cell != start_pos and current_cell != goal_pos:
				fill_color = color_explored 
				
			# Se não foi processado, mas já foi descoberto, ele está na Fronteira (Open Set)
			elif explored.has(current_cell) and current_cell != start_pos and current_cell != goal_pos:
				fill_color = color_frontier
			
			draw_rect(rect, fill_color)
			draw_rect(rect, line_color, false, 1.5)

	if path.size() > 1:
		var points = PackedVector2Array()
		for cell in path:
			points.append(Vector2(cell.x * tile_size + tile_size/2.0, cell.y * tile_size + tile_size/2.0))
		draw_polyline(points, color_path, 4.0, true)

	var start_center = Vector2(start_pos.x * tile_size + tile_size/2.0, start_pos.y * tile_size + tile_size/2.0)
	draw_circle(start_center, tile_size * 0.35, color_start)
	
	if goal_pos != Vector2i(-1, -1):
		var margin = tile_size * 0.25
		var tl = Vector2(goal_pos.x * tile_size + margin, goal_pos.y * tile_size + margin) 
		var br = Vector2((goal_pos.x + 1) * tile_size - margin, (goal_pos.y + 1) * tile_size - margin) 
		var tr = Vector2((goal_pos.x + 1) * tile_size - margin, goal_pos.y * tile_size + margin) 
		var bl = Vector2(goal_pos.x * tile_size + margin, (goal_pos.y + 1) * tile_size - margin) 
		
		draw_line(tl, br, color_goal, 3.0, true)
		draw_line(tr, bl, color_goal, 3.0, true)

func update_path():
	# Aborta qualquer busca que esteja acontecendo agora (Corrotina)
	if current_search != null:
		current_search.cancelled = true
		
	var graph = GridGraph.new(cols, rows, walls)
	var my_search: SearchAlgorithm
	
	# Instancia a IA escolhida pelo usuário
	match selected_algorithm:
		AlgoType.BFS:
			my_search = BFS.new(graph)
		AlgoType.DIJKSTRA:
			my_search = Dijkstra.new(graph)
		AlgoType.GREEDY:
			my_search = Greedy.new(graph)
		AlgoType.ASTAR:
			my_search = AStar.new(graph)
			
	current_search = my_search
	
	path.clear()
	explored = my_search.visited 
	queue_redraw()
	
	# Inicia a busca com a animação
	var result = await my_search.solve(start_pos, goal_pos, get_tree(), queue_redraw)
	
	# Só desenha o caminho se esta busca não foi cancelada no meio do caminho
	if my_search == current_search and not my_search.cancelled:
		path = result
		queue_redraw()

# Limpa o visual se o usuário editar o mapa
func clear_visuals():
	if current_search != null:
		current_search.cancelled = true
	path.clear()
	explored.clear()
	queue_redraw()

func _input(event):
	var mouse_pos = get_local_mouse_position()
	var grid_pos = Vector2i(mouse_pos / tile_size)
	
	if grid_pos.x < 0 or grid_pos.x >= cols or grid_pos.y < 0 or grid_pos.y >= rows:
		return

	var map_changed = false

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			if walls.has(grid_pos):
				is_drawing_walls = false
				walls.erase(grid_pos)
			else:
				if grid_pos != start_pos and grid_pos != goal_pos:
					is_drawing_walls = true
					walls[grid_pos] = true
			map_changed = true

	elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if is_drawing_walls:
			if grid_pos != start_pos and grid_pos != goal_pos and not walls.has(grid_pos):
				walls[grid_pos] = true
				map_changed = true
		else:
			if walls.has(grid_pos):
				walls.erase(grid_pos)
				map_changed = true

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not walls.has(grid_pos) and grid_pos != start_pos:
			goal_pos = grid_pos
			map_changed = true
			
	if event is InputEventKey and event.pressed and event.keycode == KEY_C:
		walls.clear()
		map_changed = true

	if map_changed:
		clear_visuals()

# --- SINAIS DA INTERFACE ---

# Botão principal "Simular"
func _on_button_pressed():
	update_path()

# Sinais dos botões de seleção de algoritmo
func _on_bfs_pressed():
	selected_algorithm = AlgoType.BFS
	print("Algoritmo selecionado: BFS")

func _on_dijkstra_pressed():
	selected_algorithm = AlgoType.DIJKSTRA
	print("Algoritmo selecionado: Dijkstra")

func _on_greedy_pressed():
	selected_algorithm = AlgoType.GREEDY
	print("Algoritmo selecionado: Greedy")

func _on_astar_pressed():
	selected_algorithm = AlgoType.ASTAR
	print("Algoritmo selecionado: A*")
