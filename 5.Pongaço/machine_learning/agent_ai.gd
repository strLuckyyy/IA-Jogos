class_name AgentAI
extends StaticBody2D

# Exportamos a variável para você arrastar a Bola direto pelo Inspetor da Godot
@export var bola: Bola 

@onready var initial_position = self.position

var brain: NeuralNetwork
var debug_data
var debug_capture_interval: float = 0.25
var fitness: float = 0.0
var is_alive: bool = false
var _debug_capture_elapsed: float = 0.0

# Variáveis do antigo jogador.gd
var velocidade_do_jogador: int = 500
var y_minimo: float = 64
var y_maximo: float = 654

const SCREEN_WIDTH := 1280.0
const TRACKING_DEAD_ZONE := 8.0
const HIT_REWARD := 12.0
const HIT_ACCURACY_REWARD := 6.0
const ALIGNMENT_REWARD_SCALE := 2.0
const CORRECT_ACTION_REWARD_SCALE := 0.35
const WRONG_ACTION_PENALTY_SCALE := 0.20
const IDLE_TIME_REWARD_SCALE := 0.01
const MISS_PENALTY := 4.0


func _ready() -> void:
	# Nasce, cria o cérebro vazio e prepara para a rodada
	brain = NeuralNetwork.new()
	bola.agent_die.connect(die)
	reset()


func set_agent(collision: int, color: Color):
	collision_layer = collision
	collision_mask  = collision
	
	$"../Gol".set_collision(collision)
	$Sprite2D.set_self_modulate(color)
	bola.set_agent(collision, color)


func reset(fitness_alcancado: float = 0.0) -> void:
	_set_state(true)
	position = initial_position
	fitness = fitness_alcancado
	_debug_capture_elapsed = debug_capture_interval
	
	# Quando o agente renasce, ele ativa a bola e manda ela recomeçar
	if bola:
		bola.show()
		bola.set_process(true)
		bola.resetar_bola(true)


func receber_bonus() -> void:
	# Dá um bônus gigante na pontuação para incentivar a rebatida
	var erro_y = abs(bola.position.y - position.y) if bola else 0.0
	var precisao = 1.0 - clamp(erro_y / 65.0, 0.0, 1.0)
	fitness += HIT_REWARD + precisao * HIT_ACCURACY_REWARD


func _physics_process(delta: float) -> void:
	# Se estiver morto ou a bola não estiver linkada, não faz nada
	if not is_alive or not bola: 
		return

	# 1. O que a IA "enxerga" (Entradas)
	var entradas: Array[float] = get_observations()

	# 2. A IA pensa e toma uma decisão
	var decisao = brain.predict(entradas)
	if debug_data:
		_debug_capture_elapsed += delta
		if _debug_capture_elapsed >= debug_capture_interval:
			_debug_capture_elapsed = 0.0
			debug_data.capture_snapshot(self, bola, entradas, decisao)

	# 3. Executa a ação baseada na decisão
	var acao_y := 0.0
	if decisao < 0.4:
		acao_y = -1.0
		position.y -= velocidade_do_jogador * delta # Sobe
	elif decisao > 0.6:
		acao_y = 1.0
		position.y += velocidade_do_jogador * delta # Desce
	# Se ficar entre 0.4 e 0.6, fica parado

	# Impede que a IA saia da tela
	position.y = clamp(position.y, y_minimo, y_maximo)
	_apply_reward(acao_y)


func get_observations() -> Array[float]:
	if not bola:
		var empty_observations: Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
		return empty_observations

	var relative_y := _normalize_signed(bola.position.y - position.y, y_maximo - y_minimo)
	var relative_x := _normalize_signed(bola.position.x - position.x, SCREEN_WIDTH)
	var paddle_y := _normalize_range(position.y, y_minimo, y_maximo)

	var observations: Array[float] = [
		relative_y,
		relative_x,
		paddle_y,
		float(bola.nova_direcao.x),
		float(bola.nova_direcao.y),
	]
	return observations


func _apply_reward(acao_y: float) -> void:
	var delta = get_physics_process_delta_time()
	fitness += delta * IDLE_TIME_REWARD_SCALE

	if not _is_ball_moving_toward_agent():
		return

	var erro_y := bola.position.y - position.y
	var distancia_normalizada = clamp(abs(erro_y) / (y_maximo - y_minimo), 0.0, 1.0)
	fitness += (1.0 - distancia_normalizada) * ALIGNMENT_REWARD_SCALE * delta

	if abs(erro_y) <= TRACKING_DEAD_ZONE:
		if is_zero_approx(acao_y):
			fitness += CORRECT_ACTION_REWARD_SCALE * delta
		return

	var direcao_correta := 1.0 if erro_y > 0.0 else -1.0
	if acao_y == direcao_correta:
		fitness += CORRECT_ACTION_REWARD_SCALE * delta
	elif not is_zero_approx(acao_y):
		fitness -= WRONG_ACTION_PENALTY_SCALE * delta


func _apply_miss_penalty() -> void:
	if not bola:
		return

	var erro_y = abs(bola.position.y - position.y)
	var distancia_normalizada = clamp(erro_y / (y_maximo - y_minimo), 0.0, 1.0)
	fitness -= MISS_PENALTY * distancia_normalizada


func _is_ball_moving_toward_agent() -> bool:
	if not bola:
		return false
	var relative_x := bola.position.x - position.x
	return relative_x * bola.nova_direcao.x < 0.0


func _normalize_signed(value: float, max_abs_value: float) -> float:
	if max_abs_value <= 0.0:
		return 0.0
	return clamp(value / max_abs_value, -1.0, 1.0)


func _normalize_range(value: float, min_value: float, max_value: float) -> float:
	var span := max_value - min_value
	if span <= 0.0:
		return 0.0
	return clamp(((value - min_value) / span) * 2.0 - 1.0, -1.0, 1.0)


func die(_fitness_alcancado: float = 0.0) -> void:
	if is_alive and is_zero_approx(_fitness_alcancado):
		_apply_miss_penalty()
	var fitness_final := fitness if is_zero_approx(_fitness_alcancado) else _fitness_alcancado
	if debug_data:
		debug_data.mark_dead(fitness_final)

	_set_state(false)
	
	# Quando o agente morre, ele "desliga" a bola para ela não ficar quicando sozinha
	if bola:
		bola.hide()
		bola.set_process(false)


func _set_state(alive: bool) -> void:
	is_alive = alive
	
	# Desativa a caixa de colisão usando o nó filho (CollisionShape2D)
	if has_node("CollisionShape2D"):
		$CollisionShape2D.set_deferred("disabled", !alive)
	
	if alive: 
		show()
		return
	hide()
