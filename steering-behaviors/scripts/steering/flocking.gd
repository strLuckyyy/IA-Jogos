class_name Flocking
extends SteeringBehavior


var separation_weight: float = 1.5
var alignment_weight: float = 1.
var cohesion_weight: float = 1.

var perception_radius: float = 150.


func _init() -> void:
	_debug_color = Color.YELLOW


func calculate_force(agent: Agent) -> Vector2:
	var neighbors = get_neighbors(agent)
	
	if neighbors.is_empty():
		return Vector2.ZERO
	
	var separation_vec = Vector2.ZERO
	var alignment_vec = Vector2.ZERO
	var cohesion_vec = Vector2.ZERO
	var center_of_mass = Vector2.ZERO
	
	for nbr: Agent in  neighbors:
		var diff = agent.global_position - nbr.global_position
		
		separation_vec += diff.normalized() / max(diff.length(), 1.)
		alignment_vec += nbr.velocity
		center_of_mass += nbr.global_position
	
	alignment_vec /= neighbors.size()
	center_of_mass /= neighbors.size()
	
	cohesion_vec = (center_of_mass - agent.global_position).normalized()
	
	alignment_vec = alignment_vec.normalized()
	separation_vec = separation_vec.normalized()
	
	var flocking_dir = (
		separation_vec * separation_weight +
		alignment_vec * alignment_weight +
		cohesion_vec * cohesion_weight
	).normalized()
	
	var final_dir = set_up_avoidance(flocking_dir, agent, .7)
	
	_set_debug_target_pos(agent.global_position + final_dir * 60)
	
	var desired_velocity = final_dir * agent.MAX_SPEED
	var steering = desired_velocity - agent.velocity
	return steering

func get_neighbors(agent: Agent) -> Array:
	var agents = get_tree().get_nodes_in_group("agents")
	var neighbors = []
	
	for a in agents:
		if a != agent and agent.global_position.distance_to(a.global_position) < perception_radius:
			neighbors.append(a)
	return neighbors
