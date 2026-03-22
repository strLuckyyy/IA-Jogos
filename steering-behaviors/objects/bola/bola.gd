extends RigidBody2D

class_name Bola

var player_on_posses: Player = null
var last_player_on_posses: Player = null
var original_layer: int
var original_mask: int

signal on_hit(force: float, direction: Vector2)

func _ready() -> void:
	gravity_scale = 0
	original_layer = collision_layer
	original_mask = collision_mask

func _process(delta: float) -> void:
	if player_on_posses:
		global_position = player_on_posses.get_node("FootPoint").global_position

func capture_ball(new_own: Player):
	player_on_posses = new_own
	player_on_posses.set_is_ball(self, true)
	
	set_deferred("freeze", true)
	
	collision_layer = 0
	collision_mask = 0

func release_ball():
	player_on_posses.set_is_ball(null, false)
	last_player_on_posses = player_on_posses
	player_on_posses = null
	
	set_deferred("freeze", false)
	
	collision_layer = original_layer
	collision_mask = original_mask

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and player_on_posses == null:
		capture_ball(body)
