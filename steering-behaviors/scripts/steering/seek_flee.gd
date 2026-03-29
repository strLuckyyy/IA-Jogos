extends SteeringBehavior
class_name SeekFlee

var is_flee: bool = false
var target_position: Vector2 = Vector2.ZERO

func _init(_target: Vector2, _flee: bool = false) -> void:
	target_position = _target
	is_flee = _flee

func calculate_force(agent: Agent) -> Vector2:
	var desired_velocity = (target_position - agent.global_position).normalized() * agent.MAX_SPEED
	
	if is_flee:
		desired_velocity = -desired_velocity
	
	var steering = desired_velocity - agent.velocity
	return steering
