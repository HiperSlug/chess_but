extends MoveSet
class_name KingMoveSet


var type: Globals.TYPE = Globals.TYPE.KING


func _get_all_available_moves(current_board_matrix: Array[Array], piece_position: Vector2i, piece_team_is_white: bool, total_move_count: int = 0, do_king_check = true) -> Array[Move]: # virtual

	
	var availabe_moves: Array[Move]
	
	var relative_positions: Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i(1,1),
		Vector2i(-1,1),
		Vector2i(-1,-1),
		Vector2i(1,-1),
	]
	
	
	for direction: Vector2i in relative_positions:
		var new_position: Vector2i = piece_position + direction
		
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
		
		# castling
		var caslting_directions: Array[Vector2i] = [
			Vector2i.RIGHT,
			Vector2i.LEFT,
		]
		if total_move_count == 0:
			
			# clear path to a rook
			
			for dir in caslting_directions:
				
				var checked_position: Vector2i = piece_position + dir
				
				var is_clear: bool = true
				while (checked_position.x > 0) and (checked_position.x < Globals.board_length - 1):
					
					
					var contents = current_board_matrix[checked_position.x][checked_position.y]
					if contents != null:
						is_clear = false
						break
					
					checked_position += dir
				
				if not is_clear:
					continue
				
				var rook_position_x: int
				if dir == Vector2i.LEFT:
					rook_position_x = 0
				elif dir == Vector2i.RIGHT:
					rook_position_x = Globals.board_length - 1
				
				var rook_position: Vector2i = Vector2i(rook_position_x,piece_position.y)
				var piece_at_rook_position = current_board_matrix[rook_position.x][rook_position.y]
				if piece_at_rook_position != null:
					
					if piece_at_rook_position.type == Globals.TYPE.ROOK and piece_at_rook_position.team_is_white == piece_team_is_white:
						
						if piece_at_rook_position.total_move_count == 0:
							
							
							var move_once_towards_direction: Vector2i = piece_position + dir
							var move: Move = Move.new(piece_position, move_once_towards_direction, Vector2i(-1,-1))
							
							if do_king_check:
								if not Globals.board.would_move_compromise_king(move, piece_team_is_white):
									
									var castle_move: Move = Move.new(piece_position, piece_position + (dir * 2), Vector2i(-1,-1),Move.new(rook_position, piece_position + dir,Vector2i(-1,-1)))
									availabe_moves.append(castle_move)
								
								
	
	return availabe_moves
