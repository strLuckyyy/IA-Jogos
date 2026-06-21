#Este é um script puro. Ele não vai anexado a nenhuma cena. 
#Você vai iniciá-lo com class_name NeuralNetwork para poder criar "clones" dele 
#no seu jogo usando NeuralNetwork.new().
#
#O que ele guarda (Variáveis):
#- pesos (Weights): Uma matriz (Array de Arrays) com números aleatórios. 
#Eles multiplicam as entradas para tomar a decisão.
#- vieses (Biases): Valores adicionais que ajudam a rede a não travar no zero.
#
#O que ele faz (Funções):
#- _init(num_entradas, num_saidas): O construtor. Quando a raquete nascer, 
#ela chama isso para criar um cérebro vazio e preencher os pesos iniciais de forma aleatória.
#- predict(entradas: Array) -> float: A função principal. Ela recebe onde a bola está, 
#multiplica pelos pesos, soma com os vieses, passa por uma função de ativação (como a Sigmoide) e 
#devolve a decisão (ex: 0.8 para descer, 0.2 para subir).
#- mutar(taxa_de_mutacao: float): Percorre a matriz de pesos e altera alguns deles levemente. 
#Isso é o que faz a IA "tentar coisas novas" a cada geração.
#- cruzar(outro_cerebro: NeuralNetwork) -> NeuralNetwork: Pega metade dos pesos deste cérebro 
#e junta com a metade de outro cérebro vencedor, gerando um cérebro "filho" para a próxima geração.

class_name NeuralNetwork
extends RefCounted

var weights: Array[Array]
var biases:  int

func _init() -> void:
	pass


func predict(entry: Array[float]) -> float:
	return 0.

func mutate(mutation_rate: float) -> void:
	pass

func cross_data(other_brain: NeuralNetwork) -> NeuralNetwork:
	return other_brain
