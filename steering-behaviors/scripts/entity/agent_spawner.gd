extends Node2D

@export var agent_scene: PackedScene 
const MAX_AGENTS_IN_SCENE: int = 15
var agent_in_scene: int = 0
const TIME_OUT = 1.
var current_time = 0.

func _ready() -> void:
	spawn_agent()

func _process(delta: float) -> void:
	current_time += delta
	if current_time >= TIME_OUT and agent_in_scene < MAX_AGENTS_IN_SCENE:
		spawn_agent()
		
		agent_in_scene += 1
		current_time = 0.

func spawn_agent() -> void:
	if not agent_scene:
		push_warning("A cena do Agente não foi definida no Inspetor do Spawner!")
		return
	
	var new_agent = agent_scene.instantiate()
	new_agent.global_position = global_position * Vector2(1, randf())
	
	get_tree().current_scene.add_child(new_agent)
