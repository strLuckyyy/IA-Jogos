extends Node

enum Mode {
	Seek,
	Flee,
	Persuit,
	Evasion,
	Wander,
	LeaderFollowing,
	Flocking
}

@export var agent_amount: int
var can_debug: bool = false
var player: Node

signal mode_changed(new_mode: Mode)
var current_mode = Mode.Seek:
	set(value):
		current_mode = value
		mode_changed.emit(current_mode)

signal help_toggled(is_showing: bool)
var can_show_help: bool = false:
	set(value):
		can_show_help = value
		help_toggled.emit(can_show_help)

signal collision_toggled(collision: bool)
var has_collision: bool = true:
	set(value):
		has_collision = value
		collision_toggled.emit(has_collision)


var input_map = {
	"seek": Mode.Seek,
	"flee": Mode.Flee,
	"persuit": Mode.Persuit,
	"evasion": Mode.Evasion,
	"wander": Mode.Wander,
	"leader_following": Mode.LeaderFollowing,
	"flocking": Mode.Flocking
}


func _ready() -> void:
	change_global_behavior(GameManager.current_mode)


func _input(event):
	for action in input_map:
		if event.is_action_pressed(action):
			GameManager.current_mode = input_map[action]
	
	if event.is_action_pressed("toggle"):
		GameManager.can_debug = !GameManager.can_debug
	
	if event.is_action_pressed("hud_help"): can_show_help = true
	if event.is_action_released("hud_help"): can_show_help = false
	
	if event.is_action_pressed("collision_toggle"): has_collision = !has_collision
	
	if event.is_action_pressed("exit"):
		get_tree().quit()


func change_global_behavior(new_mode: Mode):
	var spawners = get_tree().get_nodes_in_group("spawner")
	player = get_tree().get_first_node_in_group("player")
	
	current_mode = new_mode
	
	for spawn: Spawner in spawners:
		Utils.create_behavior(current_mode, player)
