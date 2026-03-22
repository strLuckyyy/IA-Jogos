extends Area2D

class_name LateralHandle

var ball_ref: Player = null
var ball_direction: Vector2 = Vector2.ZERO
var ball_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("bola"):
		print("bola lateral")
		ball_ref = body.last_player_on_posses
		ball_direction = ball_ref.direction
		ball_position = ball_ref.global_position
		
		MatchManager.notify_out_ball_lateral(ball_direction, ball_position, ball_ref)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("bola"):
		print("bola fora da lateral")
