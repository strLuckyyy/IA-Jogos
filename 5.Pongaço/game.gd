extends Node2D

const BrainDebugUIScript := preload("res://machine_learning/brain_debug_ui.gd")

@onready var qtd_populacao := %QuantidadePopulacao
@onready var engine_speed := %Velocidade
@onready var geracao := %Geracao

var brain_debug_ui


func _ready() -> void:
	_setup_brain_debug_panel()


func _process(_delta: float) -> void:
	qtd_populacao.text = str("Agentes Restantes: ", GameManager.current_population)
	geracao.text = str("Geração atual: ", GameManager.current_generation)
	engine_speed.text = str("Engine Speed: ", Engine.get_time_scale())


func _setup_brain_debug_panel() -> void:
	brain_debug_ui = BrainDebugUIScript.new()
	brain_debug_ui.name = "BrainDebugPanel"
	$UI/PaineGeracao.add_child(brain_debug_ui)
	brain_debug_ui.set_debug_data_list(GameManager.brain_debug_data_list)

	var sync_debug_ui := Callable(brain_debug_ui, "set_debug_data_list")
	if not GameManager.brain_debug_data_changed.is_connected(sync_debug_ui):
		GameManager.brain_debug_data_changed.connect(sync_debug_ui)
