extends CharacterBody2D

class_name FSM

enum State {
	OFFENSE,
	DEFENSE,
	IDLE
}

enum SubState {
	WITH_BALL,
	SUPPORT,
	PRESSING,
	COVER
}

## Posição/Função do jogador em game
enum Positions {
	GOALIE,
	
	DEFENDER,
	LEFT_BACK,
	RIGHT_BACK,
	
	LEFT_MED,
	RIGHT_MID,
	CENTER_MID,
	DEFENSIVE_MID,
	ATTACK_MID,
	
	STRIKER,
	LEFT_WINGER,
	RIGHT_WINGER
}
