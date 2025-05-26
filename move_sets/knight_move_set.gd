extends MoveSet
class_name KnightMoveSet

var type: Globals.TYPE = Globals.TYPE.KNIGHT


func _get_all_available_moves(current_board_matrix: Array[Array], piece_position: Vector2i, piece_team_is_white: bool, _total_move_count: int = 0, do_king_check = true) -> Array[Move]: # virtual
	
	var availabe_moves: Array[Move]
	
	var positions: Array[Vector2i] = [
		Vector2i(2,-1),
		Vector2i(2,1),
		Vector2i(1,2),
		Vector2i(-1,2),
		Vector2i(-2,1),
		Vector2i(-2,-1),
		Vector2i(-1,-2),
		Vector2i(1,-2),
	]
	
	
	for rel_position: Vector2i in positions:
		var new_position: Vector2i = piece_position + rel_position
		
		if is_in_bounds(new_position): 
			
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
				
				
			
	
	
	return availabe_moves
