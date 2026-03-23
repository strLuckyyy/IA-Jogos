extends FSM

class_name Player

# time
var team: int
var game_positions: FSM.Positions
var is_in_game: bool

# bola
var is_with_ball: bool = false
var ball_ref: Bola = null

# linha guia - mira
@onready var guide_line = $GuideLine

# base
@export var foot_point: Marker2D
@onready var foot_point_pos = foot_point.position
var direction = Vector2.ZERO
var look_dir = Vector2.RIGHT
var speed = 400
var look_speed = 3.5

# kick
var is_kicking: bool = false
var kick_force = 1500.
var kick_impulse = Vector2.ZERO

const cd_kick = .8
var current_cd_kick = 0.


func _physics_process(delta: float) -> void:
	direction = Vector2.ZERO
	
	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	direction = direction.normalized()
	velocity = direction * speed
	
	# foot direction
	if direction != Vector2.ZERO:
		var angle_diff = look_dir.angle_to(direction)
		var dynamic_look_speed = look_speed
		
		if abs(angle_diff) > 1.5:
			dynamic_look_speed *= 3.
		
		look_dir = look_dir.lerp(direction, dynamic_look_speed * delta).normalized()
		
	foot_point.position = look_dir * 15
	update_guide_line()
	
	if Input.is_action_just_pressed("chute") and is_with_ball:
		kick_handle()
	
	if is_kicking and current_cd_kick < cd_kick:
		current_cd_kick += delta
		return
	
	is_kicking = false
	current_cd_kick = 0.
	
	move_and_slide()


func update_guide_line():
	var line_length = 50. * velocity.length() / 80
	
	if is_with_ball:
		guide_line.visible = true
		guide_line.clear_points()
		guide_line.add_point(Vector2.ZERO)
		guide_line.add_point(look_dir * line_length)
	else:
		guide_line.visible = false


func kick_handle():
	var target_offset = 25.
	
	is_kicking = true
	ball_ref.global_position = global_position + (look_dir * target_offset)
	kick_impulse = kick_force * look_dir
	
	ball_ref.apply_central_force(kick_impulse)
	ball_ref.release_ball()

func set_is_ball(ball: Bola, value: bool):
	is_with_ball = value
	ball_ref = ball
