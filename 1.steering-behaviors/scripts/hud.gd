extends Control

@onready var label_modo: Label = $CanvasLayer/Control/MarginContainer/VBoxContainer/Mode
@onready var label_target: Label = $CanvasLayer/Control/MarginContainer/VBoxContainer/Target
@onready var label_inputs: Label = $CanvasLayer/Control/MarginContainer/VBoxContainer/Inputs

var help_unhold_txt: String = "Segure Q para abrir o Command Help"
var help_hold_txt: String = "
	                COMMAND HELP
	     
	                Comandos Gerais:
	     AWSD         ->            Move o Player
	           T            ->            Ativa/Desatiav Linhas
	           E            ->            Ativa/Desativa Colisões
	     
	            Mudanca entre Modos:
	     1                  ->            Muda para Seek
	     2                  ->            Muda para Flee
	     3                  ->            Muda para Persuit
	     4                  ->            Muda para Evasion
	     5                  ->            Muda para Wander
	     6                  ->            Muda para Leader Following
	     7                  ->            Muda para Flocking
	     
	     -> Solte a tecla Q para recolher o Command Help
	     -> ESC para sair do programa
"


func _ready() -> void:
	GameManager.mode_changed.connect(_on_mode_changed)
	GameManager.help_toggled.connect(_on_help_toggled)
	_update_hud(GameManager.current_mode)


func _on_mode_changed(new_mode: GameManager.Mode) -> void:
	_update_hud(new_mode)


func _on_help_toggled(_is_showing: bool):
	label_inputs.text = _update_help_txt()


func _update_hud(mode: GameManager.Mode) -> void:
	var mode_name = GameManager.Mode.keys()[mode].capitalize()
	label_modo.text = "Modo Atual: " + mode_name
	label_inputs.text = _update_help_txt()
	
	if _mode_uses_target(mode):
		label_target.text = "Target: Player (Ativo)"
		label_target.modulate = Color.GREEN
	else:
		label_target.text = "Target: Nenhum (Comportamento Autônomo)"
		label_target.modulate = Color.GRAY


func _update_help_txt() -> String:
	if GameManager.can_show_help: return help_hold_txt
	else: return help_unhold_txt


func _mode_uses_target(mode: GameManager.Mode) -> bool:
	return mode in [
		GameManager.Mode.Seek, 
		GameManager.Mode.Flee, 
		GameManager.Mode.Persuit, 
		GameManager.Mode.Evasion,
		GameManager.Mode.LeaderFollowing,
	]
