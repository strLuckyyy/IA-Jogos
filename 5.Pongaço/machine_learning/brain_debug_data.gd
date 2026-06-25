#made by codex
class_name BrainDebugData
extends RefCounted

signal changed(debug_data)

const DECISION_UP := "Mover para cima"
const DECISION_STAY := "Permanecer parado"
const DECISION_DOWN := "Mover para baixo"
const DECISION_UNKNOWN := "Sem decisao"

var agent_name: String = "Agent"
var agent_index: int = -1
var generation: int = 0
var agent_color: Color = Color.WHITE

var is_alive: bool = true
var fitness: float = 0.0
var final_fitness: float = 0.0
var has_final_fitness: bool = false

var ball_position: Vector2 = Vector2.ZERO
var ball_direction: Vector2 = Vector2.ZERO
var ball_velocity: Vector2 = Vector2.ZERO
var ball_speed: float = 0.0
var paddle_position: Vector2 = Vector2.ZERO
var distance_to_ball: Vector2 = Vector2.ZERO

var brain_weights: Array[float] = []
var brain_bias: float = 0.0
var raw_inputs: Dictionary = {}
var input_neurons: Array[Dictionary] = []
var hidden_layers: Array[Dictionary] = []
var output_neurons: Array[Dictionary] = []
var action_neurons: Array[Dictionary] = []

var decision_value: float = 0.0
var decision_label: String = DECISION_UNKNOWN
var last_updated_msec: int = 0

var _agent_ref: WeakRef
var _ball_ref: WeakRef


func setup(agent: Node, ball: Node, display_name: String, color: Color, p_generation: int = 0, p_index: int = -1) -> void:
	agent_name = display_name
	agent_color = color
	generation = p_generation
	agent_index = p_index
	attach(agent, ball)
	mark_alive(0.0)


func attach(agent: Node, ball: Node) -> void:
	_agent_ref = weakref(agent) if agent != null else null
	_ball_ref = weakref(ball) if ball != null else null


func get_agent() -> Node:
	if _agent_ref == null:
		return null
	var agent = _agent_ref.get_ref()
	if is_instance_valid(agent) and agent is Node:
		return agent as Node
	return null


func get_ball() -> Node:
	if _ball_ref == null:
		return null
	var ball = _ball_ref.get_ref()
	if is_instance_valid(ball) and ball is Node:
		return ball as Node
	return null


func mark_alive(starting_fitness: float = 0.0) -> void:
	is_alive = true
	fitness = starting_fitness
	final_fitness = 0.0
	has_final_fitness = false
	changed.emit(self)


func mark_dead(p_final_fitness: float) -> void:
	if not is_alive and has_final_fitness:
		return
	is_alive = false
	fitness = p_final_fitness
	final_fitness = p_final_fitness
	has_final_fitness = true
	last_updated_msec = Time.get_ticks_msec()
	changed.emit(self)


func capture_from_refs() -> void:
	if not is_alive:
		return
	var agent := get_agent()
	var ball := get_ball()
	if agent == null or ball == null:
		return
	var inputs := extract_inputs(agent, ball)
	capture_snapshot(agent, ball, inputs)


func capture_snapshot(agent: Node, ball: Node, inputs: Array, network_output: Variant = null, hidden_layer_snapshots: Array = []) -> void:
	if not is_alive:
		return

	if agent != null:
		_agent_ref = weakref(agent)
	if ball != null:
		_ball_ref = weakref(ball)

	_read_world_state(agent, ball, inputs)
	_read_brain_state(agent)

	var output_value := 0.0
	if network_output == null:
		output_value = _predict_from_agent(agent, inputs)
	else:
		output_value = float(network_output)

	decision_value = output_value
	decision_label = _decision_from_value(decision_value)

	_build_input_neurons(inputs)
	if hidden_layer_snapshots.is_empty():
		_build_hidden_layers()
	else:
		set_hidden_layers(hidden_layer_snapshots)
	_build_output_neurons(decision_value)

	last_updated_msec = Time.get_ticks_msec()
	changed.emit(self)


func extract_inputs(agent: Node, ball: Node) -> Array[float]:
	if agent != null and agent.has_method("get_observations"):
		var observed: Variant = agent.call("get_observations")
		if observed is Array:
			var normalized_inputs: Array[float] = []
			for value in observed:
				normalized_inputs.append(float(value))
			return normalized_inputs

	var current_ball_position := _node_position(ball)
	var current_paddle_position := _node_position(agent)
	var current_ball_direction := _node_vector2_property(ball, "nova_direcao")
	var fallback_inputs: Array[float] = [
		clamp((current_ball_position.y - current_paddle_position.y) / 590.0, -1.0, 1.0),
		clamp((current_ball_position.x - current_paddle_position.x) / 1280.0, -1.0, 1.0),
		clamp(((current_paddle_position.y - 64.0) / 590.0) * 2.0 - 1.0, -1.0, 1.0),
		float(current_ball_direction.x),
		float(current_ball_direction.y),
	]
	return fallback_inputs


func get_status_text() -> String:
	return "Vivo" if is_alive else "Morto"


func get_row_text() -> String:
	var shown_fitness := fitness if is_alive or not has_final_fitness else final_fitness
	return "%s  %s  %.2f" % [agent_name, get_status_text(), shown_fitness]


func get_layers_for_visualization() -> Array[Dictionary]:
	var layers: Array[Dictionary] = []
	layers.append({"name": "Input Layer", "neurons": input_neurons})
	for layer in hidden_layers:
		layers.append(layer)
	layers.append({"name": "Output Layer", "neurons": output_neurons})
	layers.append({"name": "Action Scores", "neurons": action_neurons})
	return layers


func set_hidden_layers(layer_snapshots: Array) -> void:
	hidden_layers.clear()
	for layer in layer_snapshots:
		if layer is Dictionary:
			hidden_layers.append(layer.duplicate(true))


func _read_world_state(agent: Node, ball: Node, inputs: Array) -> void:
	ball_position = _node_position(ball)
	paddle_position = _node_position(agent)
	ball_direction = _node_vector2_property(ball, "nova_direcao")
	ball_speed = _node_float_property(ball, "velocidade_da_bola", 0.0)
	ball_velocity = ball_direction * ball_speed
	distance_to_ball = ball_position - paddle_position
	fitness = _node_float_property(agent, "fitness", fitness)

	raw_inputs = {
		"ball_x": ball_position.x,
		"ball_y": ball_position.y,
		"paddle_x": paddle_position.x,
		"paddle_y": paddle_position.y,
		"relative_y_norm": _array_float(inputs, 0),
		"relative_x_norm": _array_float(inputs, 1),
		"paddle_y_norm": _array_float(inputs, 2),
		"distance_y": distance_to_ball.y,
		"ball_direction_x": ball_direction.x,
		"ball_direction_y": ball_direction.y,
		"ball_speed": ball_speed,
		"ball_velocity_x": ball_velocity.x,
		"ball_velocity_y": ball_velocity.y,
	}


func _read_brain_state(agent: Node) -> void:
	brain_weights.clear()
	brain_bias = 0.0

	if agent == null:
		return
	var brain: Variant = agent.get("brain")
	if not (brain is Object):
		return
	var brain_object := brain as Object

	var weights: Variant = brain_object.get("weights")
	if weights is Array:
		for weight in weights:
			brain_weights.append(float(weight))

	var bias: Variant = brain_object.get("bias")
	if bias != null:
		brain_bias = float(bias)


func _build_input_neurons(inputs: Array) -> void:
	input_neurons = [
		_make_neuron("relative_y", "Erro Y normalizado", _array_float(inputs, 0), _signed_activation(_array_float(inputs, 0))),
		_make_neuron("relative_x", "Distancia X normalizada", _array_float(inputs, 1), _signed_activation(_array_float(inputs, 1))),
		_make_neuron("paddle_y", "Paddle Y normalizado", _array_float(inputs, 2), _signed_activation(_array_float(inputs, 2))),
		_make_neuron("ball_dir_x", "Direcao X", _array_float(inputs, 3), _signed_activation(_array_float(inputs, 3))),
		_make_neuron("ball_dir_y", "Direcao Y", _array_float(inputs, 4), _signed_activation(_array_float(inputs, 4))),
	]


func _build_hidden_layers() -> void:
	hidden_layers.clear()


func _build_output_neurons(output_value: float) -> void:
	output_neurons = [
		_make_neuron("decision_signal", "Sinal de decisao", output_value, clamp(output_value, 0.0, 1.0)),
	]

	var move_up = clamp((0.4 - output_value) / 0.4, 0.0, 1.0)
	var move_down = clamp((output_value - 0.6) / 0.4, 0.0, 1.0)
	var stay = clamp(1.0 - abs(output_value - 0.5) / 0.5, 0.0, 1.0)

	action_neurons = [
		_make_neuron("move_up", "Sobe", move_up, move_up),
		_make_neuron("stay", "Parado", stay, stay),
		_make_neuron("move_down", "Desce", move_down, move_down),
	]


func _make_neuron(id: String, label: String, value: float, activation: float) -> Dictionary:
	return {
		"id": id,
		"name": label,
		"value": value,
		"activation": clamp(activation, 0.0, 1.0),
	}


func _predict_from_agent(agent: Node, inputs: Array) -> float:
	if agent == null:
		return decision_value
	var brain: Variant = agent.get("brain")
	if not (brain is Object):
		return decision_value
	var brain_object := brain as Object
	if not brain_object.has_method("predict"):
		return decision_value
	return float(brain_object.call("predict", inputs))


func _decision_from_value(value: float) -> String:
	if value < 0.4:
		return DECISION_UP
	if value > 0.6:
		return DECISION_DOWN
	return DECISION_STAY


func _node_position(node: Node) -> Vector2:
	if node is Node2D:
		return (node as Node2D).position
	return Vector2.ZERO


func _node_vector2_property(node: Node, property_name: StringName, default_value: Vector2 = Vector2.ZERO) -> Vector2:
	if node == null:
		return default_value
	var value: Variant = node.get(property_name)
	if value is Vector2:
		return value
	return default_value


func _node_float_property(node: Node, property_name: StringName, default_value: float = 0.0) -> float:
	if node == null:
		return default_value
	var value: Variant = node.get(property_name)
	return float(value) if value != null else default_value


func _array_float(values: Array, index: int, default_value: float = 0.0) -> float:
	if index < 0 or index >= values.size():
		return default_value
	return float(values[index])


func _normalize_abs(value: float, max_abs_value: float) -> float:
	if max_abs_value <= 0.0:
		return 0.0
	return clamp(abs(value) / max_abs_value, 0.0, 1.0)


func _signed_activation(value: float) -> float:
	return (clamp(value, -1.0, 1.0) + 1.0) * 0.5
