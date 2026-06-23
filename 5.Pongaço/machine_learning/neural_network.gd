class_name NeuralNetwork
extends RefCounted

var weights: Array[float] = [0.0, 0.0, 0.0]
var bias: float = 0.0

func _init() -> void:
	# Inicializa os pesos e o viés com valores aleatórios entre -1.0 e 1.0
	for i in range(3):
		weights[i] = randf_range(-1.0, 1.0)
	bias = randf_range(-1.0, 1.0)


func predict(entry: Array[float]) -> float:
	var sum: float = 0.0
	# Multiplica cada entrada pelo seu peso respectivo
	for i in range(3):
		sum += entry[i] * weights[i]
	
	sum += bias
	
	# Função Sigmoide: comprime qualquer resultado para um número entre 0.0 e 1.0
	return 1.0 / (1.0 + exp(-sum))


func mutate(mutation_rate: float) -> void:
	# Altera levemente os pesos para a IA "tentar coisas novas"
	for i in range(3):
		if randf() < mutation_rate:
			weights[i] += randf_range(-0.5, 0.5)
			
	if randf() < mutation_rate:
		bias += randf_range(-0.5, 0.5)


func cross_data(other_brain: NeuralNetwork) -> NeuralNetwork:
	var child = NeuralNetwork.new()
	# 50% de chance de herdar o neurônio do Pai ou da Mãe
	for i in range(3):
		child.weights[i] = self.weights[i] if randf() > 0.5 else other_brain.weights[i]
	
	child.bias = self.bias if randf() > 0.5 else other_brain.bias
	return child
