extends Node2D


@onready var qtd_populacao := %QuantidadePopulacao
@onready var engine_speed := %Velocidade
@onready var geracao := %Geracao


func _process(_delta: float) -> void:
	qtd_populacao.text = str("Agentes Restantes: ", GameManager.current_population)
	geracao.text = str("Geração atual: ", GameManager.current_generation)
	engine_speed.text = str("Engine Speed: ", Engine.get_time_scale())
