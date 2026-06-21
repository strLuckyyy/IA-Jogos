class_name Utils
extends Node


static func create_behavior(mode: GameManager.Mode, target: Node2D) -> SteeringBehavior:
	match mode:
		GameManager.Mode.Seek:
			return Seek.new(target)
		GameManager.Mode.Flee:
			return Flee.new(target)
		GameManager.Mode.Persuit:
			return Persuit.new(target)
		GameManager.Mode.Evasion:
			return Evasion.new(target)
		GameManager.Mode.Wander:
			return Wander.new()
		GameManager.Mode.LeaderFollowing:
			return LeaderFollownig.new(target)
		GameManager.Mode.Flocking:
			return Flocking.new()
	return null
