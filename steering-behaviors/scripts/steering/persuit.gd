class_name Persuit
extends SteeringBehavior

var target: Player
var last_future_pos = Vector2.ZERO


func _init(_target: Player) -> void:
	target = _target
	_debug_color = Color.MEDIUM_PURPLE


func calculate_force(agent: Agent) -> Vector2:	
	var distance = (target.global_position - agent.global_position).length()
	var predict = min(distance / max(agent.MAX_SPEED, .1), 1.2)
	var absolute_future_pos = target.global_position + (target.velocity * predict)
	
	last_future_pos = to_local(absolute_future_pos)
	_set_debug_target_pos(absolute_future_pos)
	
	var desired_velocity = (
		absolute_future_pos - agent.global_position
		).normalized() * agent.MAX_SPEED
	
	var steering = desired_velocity - agent.velocity
	return steering
