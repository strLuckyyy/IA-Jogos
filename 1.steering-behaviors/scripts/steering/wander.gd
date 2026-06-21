class_name Wander
extends SteeringBehavior

var circle_dist: float = 150.
var circle_rad: float = 80.

var wander_jitter: float = .5
var wander_angle: float = 0.


func _init() -> void:
	_debug_color = Color.ORANGE
	wander_angle = randf() * TAU


func calculate_force(agent: Agent) -> Vector2:
	wander_angle += randf_range(-1., 1.) * wander_jitter * get_physics_process_delta_time()
	
	var agent_dir = agent.velocity.normalized()
	if agent_dir.length() < .1:
		agent_dir = Vector2.RIGHT.rotated(agent.rotation)
	
	var circle_center = agent.global_position + agent_dir * circle_dist
	
	var displacement = Vector2.RIGHT.rotated(wander_angle + agent_dir.angle()) * circle_rad
	var target_pos = circle_center + displacement
	
	var wander_dir = (target_pos - agent.global_position).normalized()
	var final_dir = set_up_avoidance(wander_dir, agent, .6)
	
	_set_debug_target_pos(target_pos)
	
	var desired_velocity = final_dir * agent.MAX_SPEED
	var steering = desired_velocity - agent.velocity
	return steering
