extends Node2D

var capsula_parede_cena: PackedScene = preload("res://scenes/wall_training.tscn")
var tamanho_populacao: int = 30
var current_population: int = self.tamanho_populacao
var current_generation: int = 1

var capsulas_ativas: Array[Node2D] = []
var proxima_geracao_cerebros: Array[NeuralNetwork] = []


func _ready() -> void:
	# Acelera o tempo do jogo para treinar a IA muito mais rápido. 
	# (Mude para 1.0 se quiser assistir o jogo em velocidade normal)
	#Engine.time_scale = 3.0 
	start_generation()


func _process(_delta: float) -> void:
	check_end_generation()
	
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
	
	for i in range(tamanho_populacao):
		var capsula = capsula_parede_cena.instantiate()
		
		capsula.position = Vector2(0, 0)
		add_child(capsula)
		capsulas_ativas.append(capsula)
		
		var agente = capsula.get_node("Jogador") as AgentAI
		
		if proxima_geracao_cerebros.size() > 0:
			agente.brain = proxima_geracao_cerebros[i]
		
		var r = randf_range(0, 1)
		var g = randf_range(0, 1)
		var b = randf_range(0, 1)
		agente.set_agent(1 << i, Color(r, g, b, 1.0))
		
		agente.reset()


func check_end_generation() -> void:
	if capsulas_ativas.is_empty(): 
		return
	
	var vivos_neste_frame: int = 0
	
	for capsula in capsulas_ativas:
		var agente = capsula.get_node("Jogador")
		if agente.is_alive:
			vivos_neste_frame += 1
	
	current_population = vivos_neste_frame
	
	if current_population == 0:
		evoluir_populacao()


func evoluir_populacao() -> void:
	# Coletar e ordenar os agentes pelo fitness (do melhor para o pior)
	var rank: Array[Dictionary] = []
	for capsula in capsulas_ativas:
		var agente = capsula.get_node("Jogador")
		rank.append({"brain": agente.brain, "fitness": agente.fitness})
	
	rank.sort_custom(func(a, b): return a["fitness"] > b["fitness"])
	
	var melhor_fitness = rank[0]["fitness"]
	print("Geração ", current_generation, " finalizada! Melhor Fitness: ", 
	snapped(melhor_fitness, 0.01))
	
	salvar_historico_csv(current_generation, melhor_fitness)
	
	# Elitismo: Salva os 5 melhores cérebros intactos para a próxima geração
	proxima_geracao_cerebros.clear()
	for i in range(5):
		proxima_geracao_cerebros.append(rank[i]["brain"])
		
	# Cruzamento e Mutação: Gera os 45 "filhos" restantes
	for i in range(25):
		# Sorteia dois pais aleatórios entre os 10 melhores
		var pai = rank[randi() % 10]["brain"]
		var mae = rank[randi() % 10]["brain"]
		
		var filho = pai.cross_data(mae)
		filho.mutate(0.1) # 10% de chance de alterar os pesos neurais
		
		proxima_geracao_cerebros.append(filho)
	
	for capsula in capsulas_ativas:
		capsula.queue_free()
	
	current_generation += 1
	
	call_deferred("start_generation")


func salvar_historico_csv(geracao: int, melhor_fitness: float) -> void:
	var file
	if FileAccess.file_exists("user://historico_treino.csv"):
		file = FileAccess.open("user://historico_treino.csv", FileAccess.READ_WRITE)
		file.seek_end()
	else:
		file = FileAccess.open("user://historico_treino.csv", FileAccess.WRITE)
		file.store_line("Geracao,Melhor_Fitness")
	
	file.store_line(str(geracao) + "," + str(snapped(melhor_fitness, 0.01)))
