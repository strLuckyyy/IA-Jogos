class_name Flee
extends SteeringBehavior

var target


func _init(_target: Player) -> void:
	target = _target
	_debug_color = Color.RED


func calculate_force(agent: Agent) -> Vector2:
	var flee_dir = (agent.global_position - target.global_position).normalized()
	var final_dir = set_up_avoidance(flee_dir, agent, .6)
	
	var global_target_point = agent.global_position + (final_dir * 60)
	_set_debug_target_pos(global_target_point)
	
	var desired_velocity = final_dir * agent.MAX_SPEED
	var steering = desired_velocity - agent.velocity
	return steering
