extends Area2D


@onready var impacto_gol: AudioStreamPlayer2D = %AudioImpactoGol

func set_collision(collision: int):
	collision_layer = collision
	collision_mask = collision

func _on_area_entered(area: Area2D) -> void:
	if area is not Bola: return
	var ball = area as Bola
	
	#impacto_gol.play()
	ball.resetar_bola(false)
