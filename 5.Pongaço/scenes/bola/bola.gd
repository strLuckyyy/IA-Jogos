class_name Bola
extends Area2D

signal agent_die(fitness_alcancado: float)

# Movimento
const MAX_VELOCIDADE : float = 500.
var velocidade_da_bola : float = 500.
var posicao_inicial : Vector2 = Vector2(640, 360)
var nova_direcao : Vector2 = Vector2(0, 0)

# Efeitos Sonoros
@onready var som_impacto_barreira : AudioStreamPlayer2D = $SomImpactoBarreira
@onready var som_impacto_jogador : AudioStreamPlayer2D = $SomImpactoJogador

func _ready() -> void:
	resetar_bola()


func _process(delta):
	movimentar_bola(delta)


func resetar_bola(start: bool = true) -> void:
	# Centraliza a Bola e a manda para uma direção aleatória
	velocidade_da_bola = MAX_VELOCIDADE
	position = posicao_inicial
	escolher_direcao_inicial()
	if not start: agent_die.emit()


func escolher_direcao_inicial() -> void:
	# Escolhe as direções Horizontal e Vertical
	var x_aleatorio = [-1, 1].pick_random()
	var y_aleatorio = [-1, 1].pick_random()
	
	# Aplica as novas direções
	nova_direcao = Vector2(x_aleatorio, y_aleatorio)


func movimentar_bola(delta : float) -> void:
	# Movimenta a Bola
	position += nova_direcao * velocidade_da_bola * delta


func _on_body_entered(body):
	# Manda a Bola na direção contrária ao colidir com os jogadores
	if body.is_in_group("jogadores"):
		nova_direcao.x *= -1
		som_impacto_jogador.play()
		velocidade_da_bola *= 1.1
	
	elif body.is_in_group("paredes"):
		# Usar -abs() garante que ela SEMPRE vá para a esquerda (negativo)
		nova_direcao.x = -abs(nova_direcao.x)
		som_impacto_barreira.play()
	
	elif body.is_in_group("tetos"):
		nova_direcao.y *= -1
		som_impacto_barreira.play()
