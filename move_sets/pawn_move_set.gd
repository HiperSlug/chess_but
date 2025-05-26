extends MoveSet
class_name PawnMoveSet


var type: Globals.TYPE = Globals.TYPE.PAWN


func _get_all_available_moves(current_board_matrix: Array[Array], piece_position: Vector2i, piece_team_is_white: bool, total_move_count: int = 0, do_king_check = true) -> Array[Move]: # virtual
	var available_moves: Array[Move]
	
	var forward_direction: int
	if piece_team_is_white:
		forward_direction = -1
	else:
		forward_direction = 1
	
	
	
	# move forward one & move forward two on first move
	var forward_one_position: Vector2i = Vector2i(piece_position.x, piece_position.y + forward_direction)
	if is_in_bounds(forward_one_position):
		
		var piece_in_front = current_board_matrix[forward_one_position.x][forward_one_position.y]
		if piece_in_front == null:
			
			var move_forward: Move = Move.new(piece_position, forward_one_position, Vector2i(-1,-1))
			if do_king_check:
				if not Globals.board.would_move_compromise_king(move_forward,piece_team_is_white):
					available_moves.append(move_forward)
			else:
				available_moves.append(move_forward)
			
			# move forward two on first move
			if total_move_count == 0:
				
				var forward_two_position: Vector2i = Vector2i(piece_position.x, piece_position.y + (forward_direction * 2))
				if is_in_bounds(forward_two_position):
					
					var piece_two_tiles_in_front = current_board_matrix[forward_two_position.x][forward_two_position.y]
					if piece_two_tiles_in_front == null:
						
						var move_forward_two: Move = Move.new(piece_position,forward_two_position,Vector2i(-1,-1))
						if do_king_check:
							if not Globals.board.would_move_compromise_king(move_forward_two,piece_team_is_white):
								available_moves.append(move_forward_two)
						else:
							available_moves.append(move_forward_two)
	
	
	# diagonally attack & en passant
	var diagonal_positions: Array[Vector2i] = [
		Vector2i(piece_position.x + 1, piece_position.y + forward_direction),
		Vector2i(piece_position.x - 1, piece_position.y + forward_direction),
	]
	
	for diagonal_position: Vector2i in diagonal_positions:
		
		if is_in_bounds(diagonal_position):
			var piece_at_position = current_board_matrix[diagonal_position.x][diagonal_position.y]
			
			if piece_at_position != null:
				
				var piece_is_enemey: bool = (piece_at_position.team_is_white == not piece_team_is_white)
				if piece_is_enemey:
				
					var attack_diagonally: Move = Move.new(piece_position, diagonal_position, diagonal_position)
					if do_king_check:
						if not Globals.board.would_move_compromise_king(attack_diagonally,piece_team_is_white):
							available_moves.append(attack_diagonally)
					else:
						available_moves.append(attack_diagonally)
		
			# en passant
			else: 
				var adjacent_position: Vector2i = Vector2i(diagonal_position.x,piece_position.y)
				var adjacent_piece = current_board_matrix[adjacent_position.x][adjacent_position.y]
				
				if adjacent_piece != null:
					 
					var is_pawn: bool = (adjacent_piece.type == Globals.TYPE.PAWN)
					var is_enemy: bool = (adjacent_piece.team_is_white == not piece_team_is_white)
					if is_pawn and is_enemy:
						
						var last_move: Move = Globals.board.get_last_move()
						if last_move.final_position == adjacent_position:
							
							var change_in_position: int = last_move.final_position.y - last_move.inital_position.y
							var pawn_did_double_time_last_move: bool = (abs(change_in_position) == 2)
							if pawn_did_double_time_last_move:
								
								var en_passant: Move = Move.new(piece_position,diagonal_position,adjacent_position)
								if do_king_check:
									if not Globals.board.would_move_compromise_king(en_passant,piece_team_is_white):
										available_moves.append(en_passant)
								else:
									available_moves.append(en_passant)
	
	
	
	return available_moves
