extends RigidBody2D

class_name Bola

@onready var animation: AnimationPlayer = $AnimationPlayer
var player_on_posses: Player = null
var last_player_on_posses: Player = null

var current_vel: int

var original_layer: int
var original_mask: int

signal on_hit(force: float, direction: Vector2)

func _ready() -> void:
	gravity_scale = 0
	original_layer = collision_layer
	original_mask = collision_mask

func _physics_process(delta: float) -> void:
	current_vel = linear_velocity.length()
	
	if player_on_posses:
		current_vel = player_on_posses.velocity.length()
	
	if current_vel > 10.0: 
		animation.play("ball/roll")
		animation.speed_scale = current_vel / (500 if player_on_posses else 100)
	else:
		animation.stop()
	
	if player_on_posses:
		global_position = player_on_posses.get_node("FootPoint").global_position
		animation.speed_scale = linear_velocity.length() / 500

func capture_ball(new_own: Player):
	player_on_posses = new_own
	player_on_posses.set_is_ball(self, true)
	
	set_deferred("freeze", true)
	
	collision_layer = 0
	collision_mask = 0

func release_ball():
	if player_on_posses == null: return
	
	player_on_posses.set_is_ball(null, false)
	last_player_on_posses = player_on_posses
	player_on_posses = null
	
	set_deferred("freeze", false)
	
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	collision_layer = original_layer
	collision_mask = original_mask

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and player_on_posses == null:
		capture_ball(body)
