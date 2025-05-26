extends RefCounted
class_name Piece


static var counter: int = 0
var piece_id: int

func _init(_type: TYPE, _team_is_white: bool, base_move_set: MoveSet) -> void:
	self.type = _type
	self.team_is_white = _team_is_white
	self.move_sets.append(base_move_set)
	self.piece_id = counter
	counter += 1

enum TYPE {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}
var type: TYPE

var team_is_white: bool

var total_move_count: int = 0

var move_sets: Array[MoveSet] = []
func get_all_available_moves(board: Board, piece_position: Vector2i) -> Array[Move]:
	var available_moves: Array[Move]
	
	for move_set: MoveSet in move_sets:
		var move_set_availabel_moves: Array[Move] = move_set._get_all_available_moves(board, piece_position)
		available_moves.append_array(move_set_availabel_moves)
	
	return available_moves

func kill(piece: Piece) -> void:
	var enemy_movesets: Array[MoveSet] = piece.move_sets
	
	move_sets.append_array(enemy_movesets)

func remove_move_set(move_set: MoveSet) -> bool:
	var team_is_white: bool = move_set.team_is_white
	move_sets.erase(move_set)
	return team_is_white
	

func add_move_set(move_set: MoveSet) -> void:
	move_sets.append(move_set)
