class_name Seek
extends SteeringBehavior

var target: Player


func _init(_target: Player) -> void:
	target = _target
	_debug_color = Color.GREEN


func calculate_force(agent: Agent) -> Vector2:
	_set_debug_target_pos(target.global_position)
	
	var desired_velocity = (
		target.global_position - agent.global_position
		).normalized() * agent.MAX_SPEED
	
	var steering = desired_velocity - agent.velocity
	return steering
