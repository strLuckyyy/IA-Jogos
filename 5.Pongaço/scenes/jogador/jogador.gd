class_name Jogador
extends StaticBody2D

# Movimento
var velocidade_do_jogador : int = 500

# Limites
var y_minimo : float = 64
var y_maximo : float = 654


func _process(delta):
	movimentar_jogador(delta)
	limitar_movimento_do_jogador()


func movimentar_jogador(delta: float) -> void:
	var cima:  String = "mv-cima-2"
	var baixo: String = "mv-baixo-2"
	
	_movimentar(delta, cima, baixo)


func _movimentar(delta, input_cima: String, input_baixo: String):
	if Input.is_action_pressed(input_cima):
		position.y -= velocidade_do_jogador * delta
	elif Input.is_action_pressed(input_baixo):
		position.y += velocidade_do_jogador * delta


func limitar_movimento_do_jogador() -> void:
	# Impede que o jogador saia da tela
	position.y = clamp(position.y, y_minimo, y_maximo)
