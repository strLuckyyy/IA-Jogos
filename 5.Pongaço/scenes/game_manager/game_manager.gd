extends Node2D

signal brain_debug_data_changed(debug_data_list: Array)

const BrainDebugDataScript := preload("res://machine_learning/brain_debug_data.gd")
const CapsulaParedeCena: PackedScene = preload("res://scenes/wall_training.tscn")

var tamanho_populacao: int = 30
var current_population: int = self.tamanho_populacao
var current_generation: int = 1

var capsulas_ativas: Array[Node2D] = []
var agentes_ativos: Array[AgentAI] = []
var proxima_geracao_cerebros: Array[NeuralNetwork] = []
var brain_debug_data_list: Array = []
var brain_debug_enabled: bool = true
var print_training_log: bool = true
var _history_file: FileAccess


func _ready() -> void:
	# acelera o tempo pra treinar mais rápido
	# (deixa 1.0 se quiser ver o jogo em velocidade normal)
	#Engine.time_scale = 3.0 
	start_generation()


func _process(_delta: float) -> void:
	check_end_generation()
	
	if Input.is_action_just_pressed("ui_accept"):
		evoluir_populacao()
	
	if Input.is_action_just_pressed("debug"):
		brain_debug_enabled = not brain_debug_enabled
	
	if Input.is_action_just_pressed("reiniciar"):
		get_tree().reload_current_scene()
	
	if Input.is_action_just_pressed("sair"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("aumentar_velocidade"):
		Engine.time_scale += 0.5
	
	if Input.is_action_just_pressed("diminuir_velocidade"):
		Engine.time_scale -= 0.5


func start_generation() -> void:
	capsulas_ativas.clear()
	agentes_ativos.clear()
	brain_debug_data_list.clear()
	
	for i in range(tamanho_populacao):
		var capsula = CapsulaParedeCena.instantiate()
		
		capsula.position = Vector2(0, 0)
		add_child(capsula)
		capsulas_ativas.append(capsula)
		
		var agente = capsula.get_node("Jogador") as AgentAI
		agentes_ativos.append(agente)
		
		if proxima_geracao_cerebros.size() > 0:
			agente.brain = proxima_geracao_cerebros[i]
		
		var r = randf_range(0, 1)
		var g = randf_range(0, 1)
		var b = randf_range(0, 1)
		var agent_color := Color(r, g, b, 1.0)
		agente.set_agent(1 << i, agent_color)

		if brain_debug_enabled:
			var debug_data := BrainDebugDataScript.new()
			debug_data.setup(
				agente,
				agente.bola,
				"Agent_%02d" % (i + 1),
				agent_color,
				current_generation,
				i + 1
			)
			agente.debug_data = debug_data
			debug_data.capture_from_refs()
			brain_debug_data_list.append(debug_data)
		else:
			agente.debug_data = null
		
		agente.reset()

	if brain_debug_enabled:
		brain_debug_data_changed.emit(brain_debug_data_list)


func check_end_generation() -> void:
	if capsulas_ativas.is_empty(): 
		return
	
	var vivos_neste_frame: int = 0
	
	for agente in agentes_ativos:
		if agente.is_alive:
			vivos_neste_frame += 1
	
	current_population = vivos_neste_frame
	
	if current_population == 0:
		evoluir_populacao()


func evoluir_populacao() -> void:
	# ordena os agentes do melhor pro pior fitness
	var rank: Array[Dictionary] = []
	for agente in agentes_ativos:
		rank.append({"brain": agente.brain, "fitness": agente.fitness})
	
	rank.sort_custom(func(a, b): return a["fitness"] > b["fitness"])
	
	var melhor_fitness = rank[0]["fitness"]
	if print_training_log:
		print("Geracao ", current_generation, " finalizada! Melhor Fitness: ", snapped(melhor_fitness, 0.01))
	
	salvar_historico_csv(current_generation, melhor_fitness)
	
	# elitismo: os 5 melhores passam direto pra próxima geração
	proxima_geracao_cerebros.clear()
	for i in range(5):
		proxima_geracao_cerebros.append(rank[i]["brain"])
		
	# o resto (25) nasce de cruzamento + mutação
	for i in range(25):
		# sorteia dois pais entre os 10 melhores
		var pai = rank[randi() % 10]["brain"]
		var mae = rank[randi() % 10]["brain"]
		
		var filho = pai.cross_data(mae)
		filho.mutate(0.18) # 18% de chance de mutar cada peso
		
		proxima_geracao_cerebros.append(filho)
	
	for capsula in capsulas_ativas:
		capsula.queue_free()
	
	current_generation += 1
	
	call_deferred("start_generation")


func salvar_historico_csv(geracao: int, melhor_fitness: float) -> void:
	if _history_file == null:
		var history_exists := FileAccess.file_exists("user://historico_treino.csv")
		_history_file = FileAccess.open("user://historico_treino.csv", FileAccess.READ_WRITE if history_exists else FileAccess.WRITE)
		if _history_file == null:
			return
		if history_exists:
			_history_file.seek_end()
		else:
			_history_file.store_line("Geracao,Melhor_Fitness")
		
	_history_file.store_line(str(geracao) + "," + str(snapped(melhor_fitness, 0.01)))
