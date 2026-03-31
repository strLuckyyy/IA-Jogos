class_name Spawner
extends Node2D

@export var agent_scene: PackedScene

const MAX_AGENTS_IN_SCENE: int = 15
var agent_in_scene: int = 0


func _process(delta: float) -> void:
	if agent_in_scene < MAX_AGENTS_IN_SCENE:
		spawn_agent()
		agent_in_scene += 1


func spawn_agent() -> void:
	if not agent_scene:
		push_warning("The Agent scene was not assigned in the Spawner's Inspector!")
		return
	
	var new_agent: Agent = agent_scene.instantiate()
	
	new_agent.global_position = global_position + Vector2(randf_range(-50, 50), randf_range(-50, 50))
	new_agent.velocity = Vector2.RIGHT.rotated(randf() * TAU) * 50
	
	get_tree().current_scene.add_child(new_agent)
