extends FSM

class_name Player

# time
var team: int
var game_positions: FSM.Positions
var is_in_game: bool

# bola
var is_with_ball: bool = false
var ball_ref: Bola = null

# status
var direction = Vector2.ZERO
var force = Vector2.ZERO
var speed = 400
var teleporting: bool

# timer
const tele_timer = 2.
var current_tele_timer = 0.

func _physics_process(delta: float) -> void:
	if not teleporting:
		direction = Vector2.ZERO
		force = Vector2.ZERO
		
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

		direction = direction.normalized()

		velocity = direction * speed
		
		if velocity == Vector2.ZERO:
			force = Vector2(5000, 0)
		else:
			force = Vector2(5000 * direction.x, 5000 * direction.y)
		
		if Input.get_action_strength("chute") and is_with_ball:
			print(force)
			ball_ref.apply_central_force(force)
			ball_ref.release_ball()
			
		move_and_slide()
	else:
		print(current_tele_timer, teleporting)
		if current_tele_timer < tele_timer:
			current_tele_timer += delta
		else:
			current_tele_timer = 0
			teleporting = false

func set_is_ball(ball: Bola, value: bool):
	is_with_ball = value
	ball_ref = ball
