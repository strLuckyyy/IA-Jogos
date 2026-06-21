class_name SearchNode
extends RefCounted

var cell: Vector2i
var parent: SearchNode
var g_cost: float = 0.0
var h_cost: float = 0.0

func _init(_cell: Vector2i, _parent: SearchNode = null, _g_cost: float = 0.0):
	cell = _cell
	parent = _parent
	g_cost = _g_cost

func f_cost() -> float:
	return g_cost + h_cost
