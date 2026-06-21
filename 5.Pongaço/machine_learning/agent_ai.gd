#Este script vai substituir o antigo jogador.gd no projeto que você baixou. Ele ficará na cena da Raquete.
#
#O que ele guarda (Variáveis):
#- cerebro: Uma variável que guarda uma instância da NeuralNetwork.
#- fitness: A pontuação dessa raquete (quanto tempo ela sobreviveu ou quantos rebotes ela deu).
#- esta_viva: Um booleano (true/false) para saber se ela já tomou gol ou não.
#
#O que ele faz (Funções):
#- _physics_process(delta): Em vez de ler o teclado, ele pega a posição da bola e da própria raquete, 
#coloca num Array, e manda para cerebro.predict(entradas). Com a resposta, move a raquete usando a velocity.
#- morrer(): Função chamada quando a bola passa por ela (gol). Ela muda esta_viva para false, 
#esconde a raquete (hide()) e avisa o GameManager que foi eliminada.
class_name AgentAI
extends StaticBody2D

@onready var initial_global_position = self.global_position

var brain:    NeuralNetwork
var fitness:  float
var is_alive: bool

func reset():
	_set_state(true)
	global_position = initial_global_position


func _physics_process(delta: float) -> void:
	if not is_alive: return


func die(): 
	_set_state(false)


func _set_state(alive: bool) -> void:
	is_alive = alive
	set_deferred("disabled", !alive)
	if alive: show() 
	else: hide()
