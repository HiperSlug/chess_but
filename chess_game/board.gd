extends RefCounted
class_name Board


static var board_length: int = 8

signal piece_position_changed(piece: Piece, new_position: Vector2i)
signal piece_removed(piece: Piece)

## The actual array of pieces and nothingness.
var current_board_matrix: Array[Array]

## Updates the board to how it would be after the move.
func complete_move(move: Move) -> void:
	
	var contents = get_contents_at_position(move.inital_position)
	if contents == null:
		return
	contents = contents as Piece
	
	# kill
	if move.kill_position != Vector2i(-1, -1):
		
		var killed_piece: Piece = get_contents_at_position(move.kill_position)
		contents.capture(killed_piece)
		
		set_contents_at_position_to(move.kill_position, null)
		piece_removed.emit(killed_piece)
	
	
	# move
	set_contents_at_position_to(move.final_position, contents)
	set_contents_at_position_to(move.inital_position, null)
	piece_position_changed.emit(contents, move.final_position)
	
	
	# promote
	if move.do_promotion:
		contents.promote_to_type(move.promotion_type)
	
	contents.total_move_count += 1
	
	if move.secondary_move != null:
		complete_move(move.secondary_move)

#region BOARD CREATION
## Resize board_matrix to board_length
func _init() -> void:
	current_board_matrix.resize(board_length)
	for y_array: Array in current_board_matrix:
		y_array.resize(board_length)

## Returns a copy of this object
func duplicate() -> Board:
	
	var new_board: Board = Board.new()
	
	for x: int in range(board_length):
		for y: int in range(board_length):
			
			var position: Vector2i = Vector2i(x,y)
			
			var contents = get_contents_at_position(position)
			if contents == null:
				continue
			contents = contents as Piece
			
			new_board.set_contents_at_position_to(position, contents.duplicate(true))
	
	return new_board

## Returns a copy of this board after completing the move.
func get_board_after_move(move: Move) -> Board:
	var hypothetical_board: Board = self.duplicate()
	
	hypothetical_board.complete_move(move)
	
	return hypothetical_board
#endregion


#region GETTERS
## Shorthand for current_board_matrix[position.x][position.y]
func get_contents_at_position(position: Vector2i):
	return current_board_matrix[position.x][position.y]

## Shorthand for current_board_matrix[position.x][position.y] = thing
func set_contents_at_position_to(at: Vector2i, to) -> void:
	current_board_matrix[at.x][at.y] = to

## Returns the team of the piece at the position
## null if there is no piece at the position
func get_team_at_position(position: Vector2i):
	
	var piece = get_contents_at_position(position)
	if piece == null:
		return null
	
	return piece.team_is_white

## Returns all moves of the piece at the position
func get_availabe_moves_at_position(position: Vector2i) -> Array[Move]:
	
	var piece = get_contents_at_position(position)
	if piece == null:
		return []
	
	piece = piece as Piece
	
	var moves: Array[Move] = piece.get_all_available_moves(self, position)
	return moves
#endregion


#region LOSING AND KING BEING IN CHECK
## Checks if the team has no valid moves from their position.
## This doesnt work the same as traditional chess, namely it doesnt require the king to also be in check\
## and it also means that some situations that would normally be a stalemate such as two lone kings would continue until someone forfeited.
func check_for_loss(team_is_white: bool) -> bool:
	for y: int in range(board_length):
		for x: int in range(board_length):
			
			var position: Vector2i = Vector2i(x,y)
			var contents = get_contents_at_position(position)
			if contents != null and contents.team_is_white == team_is_white:
				
				var available_moves_for_piece: Array[Move] = get_availabe_moves_at_position(position)
				if available_moves_for_piece.size() > 0:
					return false
	return true


## Creates a hypothetical board after a move, then checks of the king of the specified\
## team was being attacked.
func would_king_be_in_check_after_move(move: Move, team_is_white: bool) -> bool:
	var hypothetical_board: Board = get_board_after_move(move)
	
	# finding their king
	for x: int in range(board_length):
		for y: int in range(board_length):
			
			var position: Vector2i = Vector2i(x,y)
			var contents = hypothetical_board.get_contents_at_position(position)
			
			# is a piece
			if contents != null:
				
				# is correct piece
				var is_king: bool = (contents.type == Globals.TYPE.KING)
				var is_same_team: bool = (contents.team_is_white == team_is_white)
				if is_king and is_same_team:
					
					# figure out of the king is under attack
					var king_under_attack: bool = hypothetical_board.is_piece_at_position_being_attacked(position)
					return king_under_attack
	return false

## Basically only run for checking if the king is being attacked, however since i dont store the position of the king anywear\
## I made a more general function.
## Returns true of any available moves of the enemy team have a kill position at the pieces position.
## Otherwise false
func is_piece_at_position_being_attacked(position: Vector2i) -> bool:
	
	var piece_at_position: Piece = get_contents_at_position(position)
	
	# finding every other piece
	for x: int in board_length:
		for y: int in board_length:
			
			# is a piece and not ourselves
			var pos: Vector2i = Vector2i(x,y)
			var piece = get_contents_at_position(pos)
			if piece == null or piece == piece_at_position:
				continue
			
			# is an enemy
			if piece.team_is_white == piece_at_position.team_is_white:
				continue
			
			piece = piece as Piece
			
			var moves_of_piece: Array[Move] = piece.get_all_available_moves(self, pos, false)
			
			for move: Move in moves_of_piece:
				if move.kill_position == position:
					return true
	
	return false
#endregion


## Run by server to ensure that the clients arent just telling it to do random shit.
## First it checks of the team of the piece matches the team of the player doing the move
## Then it checks of the piece has the aforementioned move in it's available moves.
func is_move_valid(move: Move, team_is_white: bool) -> bool:
	
	var contents = get_contents_at_position(move.inital_position)
	if contents != null:
		contents = contents as Piece
		
		if contents.team_is_white != team_is_white:
			return false
		
		var moves: Array[Move] = contents.get_all_available_moves(self, move.inital_position)
		
		for real_move: Move in moves:
			if real_move.equals_except_promotion(move):
				return true
		return false
		
	else:
		return false
