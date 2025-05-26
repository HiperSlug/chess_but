extends RefCounted
class_name Piece


signal added_move_set(move_set: MoveSet)
signal removed_move_set(move_set: MoveSet)
signal type_changed()

func _init(_type: Globals.TYPE, _team_is_white: bool, base_move_set: MoveSet) -> void:
	self.type = _type
	self.team_is_white = _team_is_white
	self.move_sets.append(base_move_set)

var type: Globals.TYPE:
	set(value):
		type = value
		type_changed.emit()
var team_is_white: bool
var total_move_count: int = 0
var move_sets: Array[MoveSet] = []


func get_all_available_moves(board_matrix: Array[Array], piece_position: Vector2i, do_king_check: bool = true) -> Array[Move]:
	var available_moves: Array[Move]
	
	for move_set: MoveSet in move_sets:
		var move_set_availabel_moves: Array[Move] = move_set._get_all_available_moves(board_matrix, piece_position, team_is_white, total_move_count, do_king_check)
		available_moves.append_array(move_set_availabel_moves)
	
	if type == Globals.TYPE.KING and do_king_check:
		var invalid_moves: Array[Move]
		for move: Move in available_moves:
			if Globals.board.is_piece_at_position_being_attacked(move.final_position, team_is_white, Globals.board.get_hypothetical_matrix_after_move(move)):
				invalid_moves.append(move)
		for invalid_move: Move in invalid_moves:
			available_moves.erase(invalid_move)
	
	return available_moves

func add_move_sets(_move_sets: Array[MoveSet]) -> void:
	for move_set: MoveSet in _move_sets:
		add_move_set(move_set)

func add_move_set(move_set: MoveSet) -> void:
	move_sets.append(move_set)
	added_move_set.emit(move_set)

func remove_move_set(move_set: MoveSet) -> bool:
	var _team_is_white: bool = move_set.team_is_white
	move_sets.erase(move_set)
	removed_move_set.emit(move_set)
	return _team_is_white
	
