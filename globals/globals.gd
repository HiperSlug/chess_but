@tool
extends Node


var board: Board

var board_length: int = 8

enum TYPE {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}


var texture_dictionary: Dictionary = { # [TYPE][TEAM_IS_WHITE]
	TYPE.PAWN: {
		true: load("res://piece_assets/wP.svg"),
		false: load("res://piece_assets/bP.svg"),
	},
	TYPE.ROOK: {
		true: load("res://piece_assets/wR.svg"),
		false: load("res://piece_assets/bR.svg"),
	},
	TYPE.KNIGHT: {
		true: load("res://piece_assets/wN.svg"),
		false: load("res://piece_assets/bN.svg"),
	},
	TYPE.BISHOP: {
		true: load("res://piece_assets/wB.svg"),
		false: load("res://piece_assets/bB.svg"),
	},
	TYPE.QUEEN: {
		true: load("res://piece_assets/wQ.svg"),
		false: load("res://piece_assets/bQ.svg"),
	},
	TYPE.KING: {
		true: load("res://piece_assets/wK.svg"),
		false: load("res://piece_assets/bK.svg"),
	},
}
