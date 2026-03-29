extends CharacterBody2D

class_name Player

const SPEED = 300.0
var direction: Vector2


func _physics_process(delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	velocity = direction * SPEED
	
	move_and_slide()
