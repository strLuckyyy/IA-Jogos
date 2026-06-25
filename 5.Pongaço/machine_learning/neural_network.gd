class_name NeuralNetwork
extends RefCounted

const INPUT_COUNT := 5

var weights: Array[float] = []
var bias: float = 0.0

func _init() -> void:
	# Inicializa os pesos e o viés com valores aleatórios entre -1.0 e 1.0
	for i in range(INPUT_COUNT):
		weights.append(randf_range(-1.0, 1.0))
	bias = randf_range(-0.25, 0.25)


func predict(entry: Array[float]) -> float:
	var sum: float = 0.0
	# Multiplica cada entrada pelo seu peso respectivo
	for i in range(min(weights.size(), entry.size())):
		sum += entry[i] * weights[i]
	
	sum += bias
	
	# Função Sigmoide: comprime qualquer resultado para um número entre 0.0 e 1.0
	return 1.0 / (1.0 + exp(-sum))


func mutate(mutation_rate: float) -> void:
	# Altera levemente os pesos para a IA "tentar coisas novas"
	for i in range(weights.size()):
		if randf() < mutation_rate:
			weights[i] = clamp(weights[i] + randf_range(-0.35, 0.35), -3.0, 3.0)
			
	if randf() < mutation_rate:
		bias = clamp(bias + randf_range(-0.2, 0.2), -2.0, 2.0)


func cross_data(other_brain: NeuralNetwork) -> NeuralNetwork:
	var child = NeuralNetwork.new()
	# 50% de chance de herdar o neurônio do Pai ou da Mãe
	for i in range(INPUT_COUNT):
		var self_weight := self.weights[i] if i < self.weights.size() else 0.0
		var other_weight := other_brain.weights[i] if i < other_brain.weights.size() else 0.0
		child.weights[i] = self_weight if randf() > 0.5 else other_weight
	
	child.bias = self.bias if randf() > 0.5 else other_brain.bias
	return child
