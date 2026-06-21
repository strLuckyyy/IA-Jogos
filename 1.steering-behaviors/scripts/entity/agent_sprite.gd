class_name AgentSprite
extends Sprite2D


func _ready() -> void:
	GameManager.mode_changed.connect(_on_mode_changed)
	_on_mode_changed(GameManager.current_mode)


func _on_mode_changed(new_mode: GameManager.Mode):
	var mode_name = GameManager.Mode.keys()[new_mode].to_lower()
	
	if has_meta(mode_name):
		var tex = get_meta(mode_name)
		if tex is Texture2D:
			self.texture = tex
