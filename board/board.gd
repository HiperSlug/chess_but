extends RefCounted
class_name Board


signal piece_position_changed(piece: Piece, new_position: Vector2i)
signal piece_removed(piece: Piece)

var board_length: int = 8
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

func get_team_at_position(position: Vector2i):
	
	var piece = get_contents_at_position(position)
	if piece == null:
		return null
	
	return piece.team_is_white

func complete_move(move: Move, check_for_promotion: bool = true, match_id: int = 0) -> void:
	
	
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
	if check_for_promotion:
		if not NetworkHandler.is_in_match or NetworkHandler.multiplayer.is_server():
			if piece.type == Globals.TYPE.PAWN:
				
				if piece.team_is_white:
					if move.final_position.y == 0:
						if NetworkHandler.multiplayer.is_server():
							NetworkHandler.promotion(match_id, piece.team_is_white, move.final_position)
						else:
							piece.get_promotion_type.emit(move.final_position)
					
				else:
					if move.final_position.y == board_length - 1:
						if NetworkHandler.multiplayer.is_server():
							NetworkHandler.promotion(match_id, piece.team_is_white, move.final_position)
						else:
							piece.get_promotion_type.emit(move.final_position)
	
	
	piece.total_move_count += 1
	
	if move.secondary_move != null:
		complete_move(move.secondary_move)
	

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

func check_for_stalemate(team_is_white: bool) -> bool:
	for y: int in range(board_length):
		for x: int in range(board_length):
			var position: Vector2i = Vector2i(x,y)
			
			var contents = get_contents_at_position(position)
			if contents != null and contents.team_is_white == team_is_white:
				contents = contents as Piece
				
				if contents.get_all_available_moves(self, position, false).size() > 0:
					return false
	return true


func get_contents_at_position(position: Vector2i):
	return current_board_matrix[position.x][position.y]

func set_contents_at_position_to(at: Vector2i, to) -> void:
	current_board_matrix[at.x][at.y] = to


func get_availabe_moves_at_position(position: Vector2i) -> Array[Move]:
	
	var piece = get_contents_at_position(position)
	if piece == null:
		return []
	
	piece = piece as Piece
	
	var moves: Array[Move] = piece.get_all_available_moves(self, position)
	return moves


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

func get_board_after_move(move: Move) -> Board:
	
	var hypothetical_board: Board = self.duplicate()
	
	hypothetical_board.complete_move(move, false)
	
	return hypothetical_board

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

func is_move_valid(move: Move, team_is_white: bool) -> bool:
	
	var contents = get_contents_at_position(move.inital_position)
	if contents != null:
		contents = contents as Piece
		
		if contents.team_is_white != team_is_white:
			return false
		
		var moves: Array[Move] = contents.get_all_available_moves(self, move.inital_position)
		
		for real_move: Move in moves:
			if real_move.equals(move):
				return true
		return false
		
	else:
		return false
