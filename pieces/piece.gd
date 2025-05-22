@tool
extends TextureRect
class_name Piece

var texture_dictionary: Dictionary = {
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

enum TYPE {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}
@export var type: TYPE:
	set(value):
		type = value
		texture = texture_dictionary[type][team_is_white]

func _ready() -> void:
	texture = texture_dictionary[type][team_is_white]


var move_sets: Array = []
@export var team_is_white: bool:
	set(value):
		team_is_white = value
		texture = texture_dictionary[type][team_is_white]

var can_promote: bool = (type == TYPE.PAWN)
var total_move_count: int = 0

func get_all_available_moves(board: Board, piece_position: Vector2i) -> Array[Move]:
	
	var available_moves: Array[Move]
	
	for move_set: MoveSet in move_sets:
		
		var move_set_availabel_moves: Array[Move] = move_set._get_all_available_moves(board, piece_position)
		available_moves.append_array(move_set_availabel_moves)
	
	return available_moves
