#made by codex
class_name BrainDebugUI
extends Control

@export var refresh_interval: float = 0.25
@export var panel_width: float = 520.0

var debug_data_list: Array = []
var selected_debug_data

var _agent_list_container: VBoxContainer
var _details_container: VBoxContainer
var _agent_buttons: Array = []
var _agent_button_data: Array = []
var _agent_button_last_text: Array = []
var _agent_button_style_keys: Array = []
var _refresh_elapsed: float = 0.0
var _last_details_data
var _last_details_updated_msec: int = -1
var _last_details_alive: bool = false
var _last_details_has_final_fitness: bool = false


func _ready() -> void:
	visible = true
	z_index = 100
	mouse_filter = Control.MOUSE_FILTER_PASS
	_fill_parent_rect()
	_build_ui()
	_refresh()


func _process(delta: float) -> void:
	if not visible:
		return

	_refresh_elapsed += delta
	if _refresh_elapsed < refresh_interval:
		return
	_refresh_elapsed = 0.0
	_refresh()


func set_debug_data_list(data_list: Array) -> void:
	debug_data_list.clear()
	for item in data_list:
		if item is Object:
			var item_object := item as Object
			if item_object.has_method("get_row_text"):
				debug_data_list.append(item_object)

	if selected_debug_data == null or not debug_data_list.has(selected_debug_data):
		selected_debug_data = debug_data_list[0] if not debug_data_list.is_empty() else null

	_refresh()


func _build_ui() -> void:
	var panel := PanelContainer.new()
	panel.name = "BrainDebugPanel"
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 1.0
	panel.offset_left = -panel_width - 12.0
	panel.offset_right = -12.0
	panel.offset_top = 12.0
	panel.offset_bottom = -12.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.06, 0.07, 0.09, 0.88), 6))
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	panel.add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	margin.add_child(root)

	var title := Label.new()
	title.text = "Brain Debug Panel"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color.WHITE)
	root.add_child(title)

	var body := HSplitContainer.new()
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.split_offset = 165
	root.add_child(body)

	var agent_list_panel := VBoxContainer.new()
	agent_list_panel.custom_minimum_size = Vector2(160, 0)
	agent_list_panel.add_theme_constant_override("separation", 6)
	body.add_child(agent_list_panel)

	var list_title := Label.new()
	list_title.text = "Agentes"
	list_title.add_theme_color_override("font_color", Color(0.86, 0.88, 0.92))
	agent_list_panel.add_child(list_title)

	var agent_scroll := ScrollContainer.new()
	agent_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	agent_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	agent_list_panel.add_child(agent_scroll)

	_agent_list_container = VBoxContainer.new()
	_agent_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_agent_list_container.add_theme_constant_override("separation", 4)
	agent_scroll.add_child(_agent_list_container)

	var details_scroll := ScrollContainer.new()
	details_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	body.add_child(details_scroll)

	_details_container = VBoxContainer.new()
	_details_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_details_container.add_theme_constant_override("separation", 8)
	details_scroll.add_child(_details_container)


func _fill_parent_rect() -> void:
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0


func _refresh() -> void:
	if _agent_list_container == null or _details_container == null:
		return

	if selected_debug_data != null and not debug_data_list.has(selected_debug_data):
		selected_debug_data = debug_data_list[0] if not debug_data_list.is_empty() else null

	_sync_agent_list()
	_rebuild_details()


func _sync_agent_list() -> void:
	if _agent_button_data.size() != debug_data_list.size():
		_rebuild_agent_list()
		return

	for i in range(debug_data_list.size()):
		if _agent_button_data[i] != debug_data_list[i]:
			_rebuild_agent_list()
			return

	_update_agent_list()


func _rebuild_agent_list() -> void:
	_clear_children(_agent_list_container)
	_agent_buttons.clear()
	_agent_button_data.clear()
	_agent_button_last_text.clear()
	_agent_button_style_keys.clear()

	for debug_data in debug_data_list:
		var button := Button.new()
		button.clip_text = true
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 34)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.add_theme_font_size_override("font_size", 11)
		button.add_theme_color_override("font_color", Color.WHITE)
		button.add_theme_color_override("font_hover_color", Color.WHITE)
		button.add_theme_color_override("font_pressed_color", Color.WHITE)
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		button.pressed.connect(_on_agent_pressed.bind(debug_data))
		_agent_list_container.add_child(button)
		_agent_buttons.append(button)
		_agent_button_data.append(debug_data)
		_agent_button_last_text.append("")
		_agent_button_style_keys.append("")

	_update_agent_list()


func _update_agent_list() -> void:
	for i in range(_agent_buttons.size()):
		var button := _agent_buttons[i] as Button
		if not is_instance_valid(button):
			_rebuild_agent_list()
			return

		var debug_data = _agent_button_data[i]
		var row_text: String = debug_data.get_row_text()
		if _agent_button_last_text[i] != row_text:
			button.text = row_text
			_agent_button_last_text[i] = row_text

		var style_key := "%s:%s" % [str(selected_debug_data == debug_data), str(debug_data.is_alive)]
		if _agent_button_style_keys[i] != style_key:
			_apply_agent_button_style(button, debug_data)
			_agent_button_style_keys[i] = style_key


func _apply_agent_button_style(button: Button, debug_data) -> void:
	var is_selected: bool = selected_debug_data == debug_data
	button.add_theme_stylebox_override("normal", _agent_row_style(debug_data, is_selected, 0.0))
	button.add_theme_stylebox_override("hover", _agent_row_style(debug_data, is_selected, 0.08))
	button.add_theme_stylebox_override("pressed", _agent_row_style(debug_data, true, 0.14))


func _rebuild_details() -> void:
	if selected_debug_data == null:
		if _last_details_data != null:
			_rebuild_details()
		return

	if (
		_last_details_data == selected_debug_data
		and _last_details_updated_msec == selected_debug_data.last_updated_msec
		and _last_details_alive == selected_debug_data.is_alive
		and _last_details_has_final_fitness == selected_debug_data.has_final_fitness
	):
		return
	
	_last_details_data = selected_debug_data
	_last_details_updated_msec = selected_debug_data.last_updated_msec if selected_debug_data != null else -1
	_last_details_alive = selected_debug_data.is_alive if selected_debug_data != null else false
	_last_details_has_final_fitness = selected_debug_data.has_final_fitness if selected_debug_data != null else false
	
	_clear_children(_details_container)

	if selected_debug_data == null:
		_add_muted_label(_details_container, "Nenhum agente registrado.")
		return

	var data = selected_debug_data
	_add_title(_details_container, data.agent_name)
	_add_key_value(_details_container, "Geracao", str(data.generation))
	_add_key_value(_details_container, "Estado", data.get_status_text())
	_add_key_value(_details_container, "Fitness atual", _format_float(data.fitness))
	if data.has_final_fitness:
		_add_key_value(_details_container, "Fitness final", _format_float(data.final_fitness))
	_add_key_value(_details_container, "Decisao atual", data.decision_label)
	_add_key_value(_details_container, "Saida bruta", _format_float(data.decision_value))
	_add_key_value(_details_container, "Cor", "#" + data.agent_color.to_html(false))

	_add_separator(_details_container)
	_add_title(_details_container, "Mundo")
	_add_key_value(_details_container, "Bola", _format_vector2(data.ball_position))
	_add_key_value(_details_container, "Paddle", _format_vector2(data.paddle_position))
	_add_key_value(_details_container, "Distancia", _format_vector2(data.distance_to_ball))
	_add_key_value(_details_container, "Direcao bola", _format_vector2(data.ball_direction))
	_add_key_value(_details_container, "Velocidade bola", _format_vector2(data.ball_velocity))

	_add_separator(_details_container)
	_add_layer_section(_details_container, "Inputs", data.input_neurons)
	_add_hidden_layers(_details_container, data.hidden_layers)
	_add_layer_section(_details_container, "Outputs", data.output_neurons)
	_add_layer_section(_details_container, "Acoes derivadas", data.action_neurons)

	_add_separator(_details_container)
	_add_title(_details_container, "Pesos e Bias")
	if data.brain_weights.is_empty():
		_add_muted_label(_details_container, "Sem pesos disponiveis.")
	else:
		for i in range(data.brain_weights.size()):
			_add_key_value(_details_container, "Peso %d" % i, _format_float(data.brain_weights[i]))
	_add_key_value(_details_container, "Bias", _format_float(data.brain_bias))


func _add_hidden_layers(parent: VBoxContainer, layers: Array[Dictionary]) -> void:
	_add_title(parent, "Hidden Layers")
	if layers.is_empty():
		_add_muted_label(parent, "Rede atual sem camada oculta.")
		return
	for layer in layers:
		var layer_name := str(layer.get("name", "Hidden Layer"))
		var neurons: Array = layer.get("neurons", [])
		_add_layer_section(parent, layer_name, neurons)


func _add_layer_section(parent: VBoxContainer, title: String, neurons: Array) -> void:
	_add_title(parent, title)
	if neurons.is_empty():
		_add_muted_label(parent, "Sem neuronios nesta camada.")
		return

	var layer_box := VBoxContainer.new()
	layer_box.add_theme_constant_override("separation", 5)
	parent.add_child(layer_box)

	for neuron in neurons:
		if neuron is Dictionary:
			_add_neuron_row(layer_box, neuron)


func _add_neuron_row(parent: VBoxContainer, neuron: Dictionary) -> void:
	var activation = clamp(float(neuron.get("activation", 0.0)), 0.0, 1.0)

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 28)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)
	parent.add_child(row)

	var dot := PanelContainer.new()
	dot.custom_minimum_size = Vector2(24, 24)
	dot.add_theme_stylebox_override("panel", _dot_style(activation))
	row.add_child(dot)

	var name_label := Label.new()
	name_label.text = str(neuron.get("name", "Neuronio"))
	name_label.clip_text = true
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	name_label.add_theme_font_size_override("font_size", 11)
	name_label.add_theme_color_override("font_color", Color(0.92, 0.94, 0.96))
	row.add_child(name_label)

	var value_label := Label.new()
	value_label.text = _format_float(float(neuron.get("value", 0.0)))
	value_label.custom_minimum_size = Vector2(62, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value_label.add_theme_font_size_override("font_size", 11)
	value_label.add_theme_color_override("font_color", Color(0.82, 0.86, 0.9))
	row.add_child(value_label)

	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 1.0
	bar.value = activation
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(64, 8)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(bar)


func _add_key_value(parent: VBoxContainer, key: String, value: String) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)

	var key_label := Label.new()
	key_label.text = key
	key_label.custom_minimum_size = Vector2(106, 0)
	key_label.add_theme_font_size_override("font_size", 11)
	key_label.add_theme_color_override("font_color", Color(0.62, 0.67, 0.74))
	row.add_child(key_label)

	var value_label := Label.new()
	value_label.text = value
	value_label.clip_text = true
	value_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	value_label.add_theme_font_size_override("font_size", 11)
	value_label.add_theme_color_override("font_color", Color.WHITE)
	row.add_child(value_label)


func _add_title(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color.WHITE)
	parent.add_child(label)


func _add_muted_label(parent: VBoxContainer, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.58, 0.62, 0.68))
	parent.add_child(label)


func _add_separator(parent: VBoxContainer) -> void:
	var separator := HSeparator.new()
	parent.add_child(separator)


func _on_agent_pressed(debug_data) -> void:
	selected_debug_data = debug_data
	_last_details_data = null
	_update_agent_list()
	_rebuild_details()


func _agent_row_style(debug_data, selected: bool, lighten_amount: float) -> StyleBoxFlat:
	var base_color = debug_data.agent_color if debug_data.is_alive else Color(0.28, 0.29, 0.31, 1.0)
	base_color = base_color.lightened(lighten_amount)
	base_color.a = 0.95

	var style := _panel_style(base_color, 5)
	if selected:
		style.border_color = Color(1.0, 0.93, 0.46, 1.0)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
	return style


func _panel_style(color: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.content_margin_left = 8
	style.content_margin_top = 6
	style.content_margin_right = 8
	style.content_margin_bottom = 6
	return style


func _dot_style(activation: float) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.14 + activation * 0.86, 0.24 + activation * 0.62, 0.30 + activation * 0.28, 0.35 + activation * 0.65)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	return style


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _format_float(value: float) -> String:
	return "%.3f" % value


func _format_vector2(value: Vector2) -> String:
	return "(%.2f, %.2f)" % [value.x, value.y]
