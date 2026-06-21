#Este script vai no nó principal da cena, gerenciando as 50 raquetes (a População).
#
#O que ele guarda (Variáveis):
#- populacao: Um Array contendo as 50 instâncias da cena AmbienteTreino (cada uma com sua raquete e bola).
#- geracao_atual: Um contador numérico.
#- historico_dados: Array ou conexão com arquivo .csv para salvar a evolução do gráfico que o professor pediu.
#
#O que ele faz (Funções):
#- iniciar_geracao(): Spawna os 50 ambientes de treino na tela e despausa o jogo.
#- checar_fim_de_geracao(): Roda no _process. Verifica o tempo todo se todas as 
#50 raquetes estão com esta_viva == false ou se o tempo limite acabou. Se sim, chama a próxima função.
#
#- evoluir_populacao(): O coração do Algoritmo Genético. O GameManager faz o seguinte:
#- - Ordena o Array populacao com base no fitness das raquetes (do maior para o menor).
#- - Pega as top 5 ou 10 melhores raquetes.
#- - Destrói as piores.
#- - Usa a função cruzar() e mutar() das melhores para criar 40 ou 45 novos "filhos".
#- - Reinicia a cena com essa nova frota de 50 ambientes e soma +1 na geracao_atual.
#
#Com essa divisão, você garante que as físicas do Pong não se misturem com a matemática da Inteligência Artificial.
extends Node2D

var population: Array[PackedScene]
var current_generation: int
var data_history: Dictionary

func start_generation() -> void:
	pass

func check_end_generation() -> void:
	pass

func grow_population() -> void:
	pass

func _process(_delta):
	# Reinicia a partida
	if Input.is_action_just_pressed("reiniciar"):
		get_tree().reload_current_scene()
	
	# Sai do jogo
	if Input.is_action_just_pressed("sair"):
		get_tree().quit()
