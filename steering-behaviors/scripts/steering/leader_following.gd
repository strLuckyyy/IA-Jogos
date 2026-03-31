class_name LeaderFollownig
extends SteeringBehavior


var leader: Player
var follow_dis: float = 60.
var slow_rad: float = 100.


func _init(_leader: Player) -> void:
	leader = _leader
	_debug_color = Color.STEEL_BLUE


func calculate_force(agent: Agent) -> Vector2:
	var leader_dir = leader.velocity.normalized()
	if leader_dir == Vector2.ZERO:
		leader_dir = Vector2.RIGHT.rotated(leader.rotation)
	
	var target_pos = leader.global_position - (leader_dir * follow_dis)
	var to_target = target_pos - agent.global_position
	var distance = to_target.length()
	
	if distance < 5.:
		return -agent.velocity * .5
	
	var desired_speed = agent.MAX_SPEED
	if distance < slow_rad:
		desired_speed = agent.MAX_SPEED * (distance / slow_rad)
	
	_set_debug_target_pos(target_pos)
	
	var desired_velocity = to_target.normalized() * desired_speed
	var steering = desired_velocity - agent.velocity
	return steering
