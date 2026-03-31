class_name Player
extends CharacterBody2D

const SPEED = 300.0
const ACCELERATION = .1
const FRICTION = .15
var direction: Vector2


func _physics_process(delta: float) -> void:
	direction = Input.get_vector("a", "d", "w", "s")
	
	if direction != Vector2.ZERO:
		velocity = velocity.lerp(direction * SPEED, ACCELERATION)
	else:
		velocity = velocity.lerp(Vector2.ZERO, FRICTION)
	
	move_and_slide()
