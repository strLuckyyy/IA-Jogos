class_name Agent
extends CharacterBody2D

const MAX_SPEED: float = 380.
const STEERING_FORCE: float = 500.

var current_behavior: SteeringBehavior

var original_collision_layer = self.collision_layer
var original_collision_mask = self.collision_mask


func _ready() -> void:
	GameManager.mode_changed.connect(_on_mode_changed)
	GameManager.collision_toggled.connect(_on_collision_toggled)
	_on_mode_changed(GameManager.current_mode)


func _physics_process(delta: float) -> void:
	if current_behavior:
		var steering_force = current_behavior.calculate_force(self)
		
		velocity += steering_force.limit_length(STEERING_FORCE) * delta
		velocity = velocity.limit_length(MAX_SPEED)
		
		if velocity.length() > 5:
			rotation = lerp_angle(rotation, velocity.angle(), .1)
	
	move_and_slide()


func _on_collision_toggled(collision: bool):
	if collision:
		self.collision_layer = original_collision_layer
		self.collision_mask = original_collision_mask
	else:
		self.collision_layer = 2
		self.collision_mask = 2


func _on_mode_changed(new_mode: GameManager.Mode):
	for child in get_children():
		if child is SteeringBehavior:
			child.queue_free()
			remove_child(child)
	
	current_behavior = Utils.create_behavior(new_mode, GameManager.player)
	if current_behavior:
		add_child(current_behavior)
