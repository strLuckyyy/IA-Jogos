class_name SteeringBehavior
extends Node2D

var _debug_target_pos = Vector2.ZERO
var _debug_color: Color = Color.DARK_CYAN

var directions = [
	Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT,
	Vector2.UP + Vector2.LEFT, Vector2.UP + Vector2.RIGHT,
	Vector2.DOWN + Vector2.LEFT, Vector2.DOWN + Vector2.RIGHT
]


func _physics_process(delta: float) -> void:
	queue_redraw()


func calculate_force(agent: Agent) -> Vector2:
	return Vector2.ZERO


func _calculate_wall(agent: Agent) -> Vector2:
	var space_state = agent.get_world_2d().direct_space_state
	var look_ahead = 60.0
	
	var agent_dir = agent.velocity.normalized()
	if agent_dir.length() < 0.1:
		agent_dir = Vector2.RIGHT.rotated(agent.rotation)
		
	var rays = [
		agent_dir * look_ahead,
		agent_dir.rotated(deg_to_rad(30)) * (look_ahead * 0.7),
		agent_dir.rotated(deg_to_rad(-30)) * (look_ahead * 0.7)
	]
	
	var avoidance_force = Vector2.ZERO
	
	for ray_vector in rays:
		var query = PhysicsRayQueryParameters2D.create(
			agent.global_position,
			agent.global_position + ray_vector
		)
		query.exclude = [agent.get_rid()]
		
		var result = space_state.intersect_ray(query)
		if not result.is_empty():
			var target_pos = result.position + result.normal * look_ahead
			avoidance_force += (target_pos - agent.global_position).normalized()
	
	return avoidance_force.normalized()


func set_up_avoidance(original_dir: Vector2, agent: Agent, force_weight: float = .8):
	var avoidance_dir = _calculate_wall(agent)
	
	if avoidance_dir != Vector2.ZERO:
		return (original_dir * (1.0 - force_weight) + avoidance_dir * force_weight).normalized()
	
	return original_dir


func _set_debug_target_pos(pos):
	if GameManager.can_debug: _debug_target_pos = to_local(pos)
	else: _debug_target_pos = Vector2.ZERO


func _draw() -> void:
	if _debug_target_pos != Vector2.ZERO:
		draw_line(Vector2.ZERO, _debug_target_pos, _debug_color, 2.)
		draw_circle(_debug_target_pos, 5., _debug_color)
