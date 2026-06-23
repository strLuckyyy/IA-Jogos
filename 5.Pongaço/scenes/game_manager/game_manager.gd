extends Node2D

var capsula_parede_cena: PackedScene = preload("res://scenes/wall_training.tscn")
var tamanho_populacao: int = 30
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
	
	# Reinicia a partida manualmente
	if Input.is_action_just_pressed("reiniciar"):
		get_tree().reload_current_scene()
	
	# Sai do jogo
	if Input.is_action_just_pressed("sair"):
		get_tree().quit()

func start_generation() -> void:
	capsulas_ativas.clear()
	
	for i in range(tamanho_populacao):
		# Instancia a cápsula
		var capsula = capsula_parede_cena.instantiate()
		
		# O Segredo da Otimização: Isola a cápsula no eixo Y
		capsula.position = Vector2(0, 0)
		add_child(capsula)
		capsulas_ativas.append(capsula)
		
		# IMPORTANTE: Garanta que o nome do nó do Agente na sua cena TreinoParede seja "Jogador"
		var agente = capsula.get_node("Jogador") as AgentAI
		
		# Se já tivermos passado da Geração 1, injetamos os cérebros evoluídos
		if proxima_geracao_cerebros.size() > 0:
			agente.brain = proxima_geracao_cerebros[i]
		
		var r = randf_range(0, 1)
		var g = randf_range(0, 1)
		var b = randf_range(0, 1)
		agente.set_agent(i + 1, Color(r, g, b, 1.0))
		
		# Chama o reset do agente para ele iniciar a rodada
		agente.reset()

func check_end_generation() -> void:
	if capsulas_ativas.is_empty(): 
		return
	
	# Verifica se todos os 50 agentes da geração já morreram
	var todos_mortos = true
	for capsula in capsulas_ativas:
		var agente = capsula.get_node("Jogador")
		if agente.is_alive:
			todos_mortos = false
			break
			
	if todos_mortos:
		evoluir_populacao()

func evoluir_populacao() -> void:
	# 1. Coletar e ordenar os agentes pelo fitness (do melhor para o pior)
	var rank: Array[Dictionary] = []
	for capsula in capsulas_ativas:
		var agente = capsula.get_node("Jogador")
		rank.append({"brain": agente.brain, "fitness": agente.fitness})
		
	# Função de ordenação
	rank.sort_custom(func(a, b): return a["fitness"] > b["fitness"])
	
	var melhor_fitness = rank[0]["fitness"]
	print("Geração ", current_generation, " finalizada! Melhor Fitness: ", snapped(melhor_fitness, 0.01))
	
	# Salva os dados no CSV para o gráfico da apresentação
	salvar_historico_csv(current_generation, melhor_fitness)
	
	# 2. Elitismo: Salva os 5 melhores cérebros intactos para a próxima geração
	proxima_geracao_cerebros.clear()
	for i in range(5):
		proxima_geracao_cerebros.append(rank[i]["brain"])
		
	# 3. Cruzamento e Mutação: Gera os 45 "filhos" restantes
	for i in range(25):
		# Torneio simples: Sorteia dois pais aleatórios entre os 10 melhores
		var pai = rank[randi() % 10]["brain"]
		var mae = rank[randi() % 10]["brain"]
		
		var filho = pai.cross_data(mae)
		filho.mutate(0.1) # 10% de chance de alterar os pesos neurais
		
		proxima_geracao_cerebros.append(filho)
		
	# 4. Destrói as cápsulas antigas para liberar memória
	for capsula in capsulas_ativas:
		capsula.queue_free()
		
	# 5. Prepara a nova geração
	current_generation += 1
	
	# call_deferred manda a Godot esperar o frame atual terminar de deletar os nós antes de criar os novos
	call_deferred("start_generation")

func salvar_historico_csv(geracao: int, melhor_fitness: float) -> void:
	# O arquivo será salvo na pasta do usuário (no Windows: %appdata%\Godot\app_userdata\pong-na-godot\)
	var file
	if FileAccess.file_exists("user://historico_treino.csv"):
		file = FileAccess.open("user://historico_treino.csv", FileAccess.READ_WRITE)
		file.seek_end() # Vai para o final do arquivo para não apagar os antigos
	else:
		file = FileAccess.open("user://historico_treino.csv", FileAccess.WRITE)
		file.store_line("Geracao,Melhor_Fitness") # Cabeçalho na primeira vez
		
	file.store_line(str(geracao) + "," + str(snapped(melhor_fitness, 0.01)))
