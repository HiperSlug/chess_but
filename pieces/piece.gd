extends RefCounted
class_name Piece


signal added_move_set(move_set: MoveSet)
signal removed_move_set(move_set: MoveSet)
signal type_changed()

func _init(_type: Globals.TYPE, _team_is_white: bool, base_move_sets: Array[MoveSet]) -> void:
	self.type = _type
	self.team_is_white = _team_is_white
	self.move_sets = base_move_sets

var type: Globals.TYPE
var team_is_white: bool
var total_move_count: int = 0
var move_sets: Array[MoveSet] = []

@warning_ignore("unused_signal") # called by board
signal get_promotion_type() # given to piece2d or piece3d to get a promotion popup

func duplicate(deep: bool = true) -> Piece:
	var new_piece: Piece = Piece.new(type, team_is_white, move_sets.duplicate(deep))
	return new_piece

func promote(new_move_set_type: Globals.TYPE) -> void:
	# change visual type
	type = new_move_set_type
	type_changed.emit()
	
	# find pawn moveset
	for move_set: MoveSet in move_sets:
		
		# same team and type
		var same_team: bool = move_set.team_is_white == team_is_white
		var pawn_type: bool = move_set.type == Globals.TYPE.PAWN 
		if same_team and pawn_type:
			
			# remove pawn moveset
			remove_move_set(move_set)
			break
	
	# add new moveset
	var new_move_set: MoveSet = MoveSet.new(new_move_set_type, team_is_white)
	add_move_set(new_move_set)

func get_all_available_moves(board: Board, piece_position: Vector2i, do_king_check: bool = true) -> Array[Move]:
	
	var available_moves: Array[Move]
	
	for move_set: MoveSet in move_sets:
		var move_set_available_moves: Array[Move] = move_set.get_all_available_moves(board, piece_position, team_is_white, total_move_count, do_king_check)
		available_moves.append_array(move_set_available_moves)
	
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

func capture(piece: Piece) -> void:
	var killed_piece_move_set: Array[MoveSet] = piece.move_sets
	add_move_sets(killed_piece_move_set)
