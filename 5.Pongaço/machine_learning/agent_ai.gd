class_name AgentAI
extends StaticBody2D

# Exportamos a variável para você arrastar a Bola direto pelo Inspetor da Godot
@export var bola: Bola 

@onready var initial_position = self.position

var brain: NeuralNetwork
var fitness: float = 0.0
var is_alive: bool = false

# Variáveis do antigo jogador.gd
var velocidade_do_jogador: int = 500
var y_minimo: float = 64
var y_maximo: float = 654


func _ready() -> void:
	# Nasce, cria o cérebro vazio e prepara para a rodada
	brain = NeuralNetwork.new()
	bola.agent_die.connect(die)
	reset()


func set_agent(collision: int, color: Color):
	collision_layer = collision
	collision_mask  = collision
	
	$"../Gol".set_collision(collision)
	$Sprite2D.set_self_modulate(color)
	bola.set_agent(collision, color)


func reset(fitness_alcancado: float = 0.0) -> void:
	_set_state(true)
	position = initial_position
	fitness = fitness_alcancado
	
	# Quando o agente renasce, ele ativa a bola e manda ela recomeçar
	if bola:
		bola.show()
		bola.set_process(true)
		bola.resetar_bola(true)


func _physics_process(delta: float) -> void:
	# Se estiver morto ou a bola não estiver linkada, não faz nada
	if not is_alive or not bola: 
		return

	# O "Score" da IA: quanto mais tempo ela sobrevive, maior o fitness
	fitness += delta

	# 1. O que a IA "enxerga" (Entradas)
	var entradas: Array[float] = [
		bola.position.y, 
		position.y, 
		float(bola.nova_direcao.x)
	]

	# 2. A IA pensa e toma uma decisão
	var decisao = brain.predict(entradas)

	# 3. Executa a ação baseada na decisão
	if decisao < 0.4:
		position.y -= velocidade_do_jogador * delta # Sobe
	elif decisao > 0.6:
		position.y += velocidade_do_jogador * delta # Desce
	# Se ficar entre 0.4 e 0.6, fica parado

	# Impede que a IA saia da tela
	position.y = clamp(position.y, y_minimo, y_maximo)


func die(_fitness_alcancado: float = 0.0) -> void:
	print(name, " died.")
	_set_state(false)
	
	# Quando o agente morre, ele "desliga" a bola para ela não ficar quicando sozinha
	if bola:
		bola.hide()
		bola.set_process(false)


func _set_state(alive: bool) -> void:
	is_alive = alive
	
	# Desativa a caixa de colisão usando o nó filho (CollisionShape2D)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", !alive)
	
	if alive: 
		show() 
	else: 
		hide()
