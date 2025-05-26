extends MoveSet
class_name BishopMoveSet

var type: Globals.TYPE = Globals.TYPE.BISHOP

func _get_all_available_moves(current_board_matrix: Array[Array], piece_position: Vector2i, piece_team_is_white: bool, _total_move_count: int = 0, do_king_check = true) -> Array[Move]: # virtual
	
	var availabe_moves: Array[Move]
	
	var directions: Array[Vector2i] = [
		# diagonals
		Vector2i(1,1),
		Vector2i(-1,1),
		Vector2i(-1,-1),
		Vector2i(1,-1),
	]
	
	
	for direction: Vector2i in directions:
		var new_position: Vector2i = piece_position + direction
		
		while is_in_bounds(new_position): 
			
			var contents = current_board_matrix[new_position.x][new_position.y]
			if contents == null:
				
				
				var move_horizontally: Move = Move.new(piece_position,new_position,Vector2i(-1,-1))
				
				if do_king_check:
					if not Globals.board.would_move_compromise_king(move_horizontally,piece_team_is_white):
						availabe_moves.append(move_horizontally)
				else:
					availabe_moves.append(move_horizontally)
				
			else:
				
				if contents.team_is_white != piece_team_is_white:
					var kill_horizontally: Move = Move.new(piece_position,new_position,new_position)
					if do_king_check:
						if not Globals.board.would_move_compromise_king(kill_horizontally,piece_team_is_white):
							availabe_moves.append(kill_horizontally)
					else:
						availabe_moves.append(kill_horizontally)
				
				break
			
			new_position += direction
	
	
	return availabe_moves
