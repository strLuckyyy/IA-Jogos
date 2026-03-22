extends Node

enum Side{ LEFT, RIGHT }
enum Team{ BLUE = 0, RED = 1 }

# signals
## Arremeço lateral(direção do arremeço, posição de cobrança, jogador que vai arremeçar) -> Caso de bola saindo pela lateral
signal throw_in(direction: Vector2, position: Vector2, kicker_player: Player)
## Tiro Livre(direção do chute, posição de cobrança, jogador que vai cobrar) -> Caso de falta em meio campo
signal free_kick(direction: Vector2, position: Vector2, kicker_player: Player)
## Tiro de Meta(time que vai cobrar) -> Caso a bola saia pela linha do gol e não atinja um jogador do time
signal goal_kick(team: Team)
## Cobraça de Penâlti(jogador que vai cobrar) -> Caso de falta dentro da pequena área
signal penalty(kicker_player: Player)
## Escanteio(jogador que vai cobrar, lado que será cobrado) -> Caso a bola saia pela linha do gol acertando algum jogador do time
signal corner_kick(kicker_player: Player, field_side: Side)
## Impedimento (direção da cobrança, posição da cobrança, jogador que cobrará) -> Caso de passe impedido
signal offside(direction: Vector2, position: Vector2, kicker_player: Player)
## Expulsão(jogador)
signal expulse(player: Player)

# camera
@export var camera: Camera2D

# bola
@export var bola: Bola

# gols
@export var right_goal: StaticBody2D
@export var left_goal: StaticBody2D
var left_team_goal: int = 0
var right_team_goal: int = 0

# arbitro
@export var Referee: CharacterBody2D

# tempo de partida
const match_time = 45.
const match_extratime = match_time / 2
var current_time = 0.

# tempos
const max_half = 4
var current_half = 1

# posição inicial dos jogadores
var blue_players = []
var blue_player_pos = []

var red_players = []
var red_players_pos = []

func _ready() -> void:
	throw_in.connect(notify_out_ball_lateral)

func notify_out_ball_lateral(direction: Vector2, position: Vector2, player: Player) -> void:
	print("lançamento lateral")
