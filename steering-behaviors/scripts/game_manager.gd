extends Node

enum Mode {
	Seek,
	Flee,
	Persuit,
	Evasion,
	Wander,
	LeaderFollowing,
	Flocking
}

@export var agent_amount: int
var current_mode = Mode.Seek


func change_global_behavior(new_mode: Mode, target_pos: Vector2):
	current_mode = new_mode
	var agents = get_tree().get_nodes_in_group("agents")
	
	for agent:Agent in agents:
		match current_mode:
			Mode.Seek:
				agent.current_behavior = SeekFlee.new(target_pos, false)
			Mode.Flee:
				agent.current_behavior = SeekFlee.new(target_pos, true)
