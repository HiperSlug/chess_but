extends RefCounted
class_name Board


signal piece_position_changed(piece: Piece, new_position: Vector2i)
signal piece_removed(piece: Piece)

func _init(board_matrix = null) -> void:
	if board_matrix != null:
		current_board_matrix = board_matrix
		return
	
	current_board_matrix.resize(Globals.board_length)
	for y_array: Array in current_board_matrix:
		y_array.resize(Globals.board_length)
	

var current_board_matrix: Array[Array]
var board_history: Array[Array]
var move_history: Array[Move]

func complete_move(move: Move) -> void:
	
	# history
	board_history.append(current_board_matrix.duplicate(true))
	move_history.append(move)
	
	
	var piece: Piece = get_contents_at(move.inital_position)
	
	# kill
	if move.kill_position != Vector2i(-1, -1):
		
		var killed_piece: Piece = get_contents_at(move.kill_position)
		piece.add_move_sets(killed_piece.move_sets)
		
		set_contents_at(move.kill_position, null)
		piece_removed.emit(killed_piece)
	
	
	# move
	set_contents_at(move.final_position, piece)
	set_contents_at(move.inital_position, null)
	piece_position_changed.emit(piece, move.final_position)
	
	if piece.type == Globals.TYPE.PAWN:
		
		if piece.team_is_white:
			
			if move.final_position.y == 0:
				print("promote")
			
		else:
			if move.final_position.y == Globals.board_length - 1:
				print("promote")
	
	piece.total_move_count += 1
	
	if move.secondary_move == null:
		return
	
	var secondary_move: Move = move.secondary_move
	
	var piece_2: Piece = get_contents_at(secondary_move.inital_position)
	
	# kill
	if secondary_move.kill_position != Vector2i(-1, -1):
		
		var killed_piece: Piece = get_contents_at(secondary_move.kill_position)
		piece_2.add_move_sets(killed_piece.move_sets)
		
		set_contents_at(secondary_move.kill_position, null)
		piece_removed.emit(killed_piece)
	
	
	# move
	set_contents_at(secondary_move.final_position, piece_2)
	set_contents_at(secondary_move.inital_position, null)
	piece_position_changed.emit(piece_2, secondary_move.final_position)
	
	piece_2.total_move_count += 1




func get_contents_at(position: Vector2i):
	return current_board_matrix[position.x][position.y]

func set_contents_at(at: Vector2i, to) -> void:
	current_board_matrix[at.x][at.y] = to


func get_last_move() -> Move:
	return move_history[-1]


func get_availabe_moves_at_position(position: Vector2i) -> Array[Move]:
	
	var piece = get_contents_at(position)
	if piece == null:
		return []
	piece = piece as Piece
	var moves: Array[Move] = piece.get_all_available_moves(self.current_board_matrix, position)
	
	return moves


func is_piece_at_position_being_attacked(position: Vector2i, _team_is_white: bool, board_matrix: Array[Array]) -> bool:
	
	var piece_at_position: Piece = board_matrix[position.x][position.y]
	
	for x: int in Globals.board_length:
		for y: int in Globals.board_length:
			
			var pos: Vector2i = Vector2i(x,y)
			var piece = get_contents_at(pos)
			if piece == null or piece == piece_at_position:
				continue
			piece = piece as Piece
			
			var moves_of_piece: Array[Move] = piece.get_all_available_moves(board_matrix, pos, false)
			
			for move: Move in moves_of_piece:
				if move.kill_position == position:
					return true
	
	return false

func get_hypothetical_matrix_after_move(move: Move) -> Array[Array]:
	
	var hypothetical_matrix: Array[Array] = current_board_matrix.duplicate(true)
	
	
	if move.kill_position != Vector2i(-1, -1):
		
		hypothetical_matrix[move.kill_position.x][move.kill_position.y] = null
	
	
	# move
	hypothetical_matrix[move.final_position.x][move.final_position.y] = hypothetical_matrix[move.inital_position.x][move.inital_position.y]
	hypothetical_matrix[move.inital_position.x][move.inital_position.y] = null
	return hypothetical_matrix

func would_move_compromise_king(move: Move, team_is_white: bool) -> bool:
	var hypotheical_matrix: Array[Array] = get_hypothetical_matrix_after_move(move)
	
	# finding their king
	for x: int in range(Globals.board_length):
		for y: int in range(Globals.board_length):
			
			var position: Vector2i = Vector2i(x,y)
			var contents = hypotheical_matrix[position.x][position.y]
			
			if contents != null and contents.type == Globals.TYPE.KING and contents.team_is_white == team_is_white:
				
				# checking if they are still in check
				return is_piece_at_position_being_attacked(position, team_is_white, hypotheical_matrix)
	return false
