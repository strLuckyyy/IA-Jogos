class_name Evasion
extends SteeringBehavior

var target: Player


func _init(_target: Player) -> void:
	target = _target


func _ready() -> void:
	_debug_color = Color.SLATE_GRAY


func calculate_force(agent: Agent) -> Vector2:
	var distance = (target.global_position - agent.global_position).length()
	var predict = min(distance / max(agent.MAX_SPEED, .1), 1.5)
	
	var future_pos = target.global_position + (target.velocity * predict)
	var evasion_dir = (agent.global_position - future_pos).normalized()
	
	var final_dir = set_up_avoidance(evasion_dir, agent)
	
	var global_target_point = agent.global_position + (final_dir * 60)
	_set_debug_target_pos(global_target_point)
	
	var steering = final_dir * agent.MAX_SPEED
	return steering - agent.velocity
