extends RefCounted
class_name Piece

# these are all self explanatory
signal added_move_set(move_set: MoveSet)
signal removed_move_set(move_set: MoveSet)
signal type_changed(new_type: Globals.TYPE)

## This is used for promotion and the display texture/model.
var type: Globals.TYPE:
	set(value):
		type = value
		type_changed.emit(type)
var team_is_white: bool
var move_sets: Array[MoveSet] = []

## Used for castling and pawn move two.
var total_move_count: int = 0

func _init(_type: Globals.TYPE, _team_is_white: bool, base_move_sets: Array[MoveSet]) -> void:
	self.type = _type
	self.team_is_white = _team_is_white
	self.move_sets = base_move_sets

## Returns a copy of this piece.
## Used when duplicating boards for testing king safety.
func duplicate(deep: bool = true) -> Piece:
	var new_piece: Piece = Piece.new(type, team_is_white, move_sets.duplicate(deep))
	return new_piece


#region MOVESETS
## This just calls add_move_set a bunch because the signals need to be emitted.
func add_move_sets(_move_sets: Array[MoveSet]) -> void:
	for move_set: MoveSet in _move_sets:
		add_move_set(move_set)

## Appends the move_set and emits the added_move_set signal.
func add_move_set(move_set: MoveSet) -> void:
	move_sets.append(move_set)
	added_move_set.emit(move_set)

## Erases the move_set from the list and emits the removed_move_set signal.
func remove_move_set(move_set: MoveSet) -> void:
	move_sets.erase(move_set)
	removed_move_set.emit(move_set)

## Adds the move_sets of the captured piece to ourselves.
func capture(piece: Piece) -> void:
	var killed_piece_move_set: Array[MoveSet] = piece.move_sets
	add_move_sets(killed_piece_move_set)

## Updates type (used for visuals and promotion), finds then removes the base pawn moveset, adds a new moveset of given type
func promote_to_type(new_type: Globals.TYPE) -> void:
	type = new_type
	
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
	var new_move_set: MoveSet = MoveSet.new(new_type, ChessGame.new(), team_is_white)
	add_move_set(new_move_set)
#endregion


## Gets all available moves of every single moveset attached to this piece and returns them as one big array.
func get_all_available_moves(board: Board, piece_position: Vector2i, do_king_check: bool = true) -> Array[Move]:
	
	var available_moves: Array[Move]
	
	for move_set: MoveSet in move_sets:
		var move_set_available_moves: Array[Move] = move_set.get_all_available_moves(board, piece_position, team_is_white, total_move_count, do_king_check)
		available_moves.append_array(move_set_available_moves)
	
	if type == Globals.TYPE.PAWN:
		
		var final_y: int
		if team_is_white:
			final_y = 0
		else:
			final_y = 7
		
		for move: Move in available_moves:
			if move.final_position.y == final_y:
				
				move.do_promotion = true
	
	return available_moves
