extends CharacterBody2D
class_name Agent

const MAX_SPEED: float = 300.
var current_speed = 0.
var current_behavior: SteeringBehavior

func _physics_process(delta: float) -> void:
	if current_behavior:
		var force = current_behavior.calculate_force(self)
		
		velocity += force * delta
		velocity = velocity.limit_length(MAX_SPEED)
	
	move_and_slide()
