extends MoveSet
class_name KnightMoveSet


func _get_all_available_moves(board: Board, piece_position: Vector2i) : #-> Array[Move]
	
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
	
	var piece: Piece = board.get_contents_at(piece_position)
	
	for rel_position: Vector2i in positions:
		var new_position: Vector2i = piece_position + rel_position
		
		if is_in_bounds(new_position): 
			
			var contents = board.get_contents_at(new_position)
			if contents == null:
				
				var move_horizontally: Move = Move.new(piece_position,new_position,Vector2i(-1,-1))
				availabe_moves.append(move_horizontally)
				
			else:
				
				if contents.team_is_white != piece.team_is_white:
					var kill_horizontally: Move = Move.new(piece_position,new_position,new_position)
					availabe_moves.append(kill_horizontally)
				
				
			
	
	
	return availabe_moves
