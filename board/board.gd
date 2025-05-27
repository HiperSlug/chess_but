extends RefCounted
class_name Board


signal piece_position_changed(piece: Piece, new_position: Vector2i)
signal piece_removed(piece: Piece)

var board_length: int
var current_board_matrix: Array[Array]

func _init(_board_length: int, board_matrix = null) -> void:
	
	if board_matrix != null:
		current_board_matrix = board_matrix
		return
	
	board_length = _board_length
	
	current_board_matrix.resize(board_length)
	for y_array: Array in current_board_matrix:
		y_array.resize(board_length)

func duplicate() -> Board:
	var new_board_matrix: Array[Array]
	new_board_matrix.resize(board_length)
	for y_array: Array in new_board_matrix:
		y_array.resize(board_length)
	
	for x: int in range(board_length):
		for y: int in range(board_length):
			var position: Vector2i = Vector2i(x,y)
			
			var contents = get_contents_at_position(position)
			if contents == null:
				continue
			
			new_board_matrix[x][y] = contents.duplicate(true)
	
	var new_board: Board = Board.new(board_length, new_board_matrix)
	return new_board

signal move_completed(move: Move)

func complete_move(move: Move) -> void:
	
	move_completed.emit(move)
	
	var piece: Piece = get_contents_at_position(move.inital_position)
	
	# kill
	if move.kill_position != Vector2i(-1, -1):
		
		var killed_piece: Piece = get_contents_at_position(move.kill_position)
		piece.capture(killed_piece)
		
		set_contents_at_position_to(move.kill_position, null)
		piece_removed.emit(killed_piece)
	
	
	# move
	set_contents_at_position_to(move.final_position, piece)
	set_contents_at_position_to(move.inital_position, null)
	piece_position_changed.emit(piece, move.final_position)
	
	# promotion
	if piece.type == Globals.TYPE.PAWN:
		
		if piece.team_is_white:
			if move.final_position.y == 0:
				piece.get_promotion_type.emit()
			
		else:
			if move.final_position.y == board_length - 1:
				piece.get_promotion_type.emit()
	
	piece.total_move_count += 1
	
	if move.secondary_move == null:
		return
	
	complete_move(move.secondary_move)



func get_contents_at_position(position: Vector2i):
	return current_board_matrix[position.x][position.y]

func set_contents_at_position_to(at: Vector2i, to) -> void:
	current_board_matrix[at.x][at.y] = to


func get_availabe_moves_at_position(position: Vector2i) -> Array[Move]:
	
	var piece = get_contents_at_position(position)
	if piece == null:
		return []
	
	var moves: Array[Move] = piece.get_all_available_moves(self, position)
	return moves


func is_piece_at_position_being_attacked(position: Vector2i) -> bool:
	
	var piece_at_position: Piece = get_contents_at_position(position)
	
	# finding every other piece
	for x: int in Globals.board_length:
		for y: int in Globals.board_length:
			
			# is a piece and not ourselves
			var pos: Vector2i = Vector2i(x,y)
			var piece = get_contents_at_position(pos)
			if piece == null or piece == piece_at_position:
				continue
			
			# is an enemy
			if piece.team_is_white == piece_at_position.team_is_white:
				continue
			
			var moves_of_piece: Array[Move] = piece.get_all_available_moves(self, pos, false)
			
			for move: Move in moves_of_piece:
				if move.kill_position == position:
					return true
	
	return false

func get_board_after_move(move: Move) -> Board:
	
	var hypothetical_board: Board = self.duplicate()
	
	hypothetical_board.complete_move(move)
	
	return hypothetical_board

func would_king_be_in_check_after_move(move: Move, team_is_white: bool) -> bool:
	var hypothetical_board: Board = get_board_after_move(move)
	
	# finding their king
	for x: int in range(Globals.board_length):
		for y: int in range(Globals.board_length):
			
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
