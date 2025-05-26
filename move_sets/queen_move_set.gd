extends MoveSet
class_name QueenMoveSet

func _get_all_available_moves(board: Board, piece_position: Vector2i) : #-> Array[Move]
	
	var availabe_moves: Array[Move]
	
	var directions: Array[Vector2i] = [
		# horizontals
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
		# diagonals
		Vector2i(1,1),
		Vector2i(-1,1),
		Vector2i(-1,-1),
		Vector2i(1,-1),
	]
	
	var piece: Piece = board.get_contents_at(piece_position)
	
	for direction: Vector2i in directions:
		var new_position: Vector2i = piece_position + direction
		
		while is_in_bounds(new_position): 
			
			var contents = board.get_contents_at(new_position)
			if contents == null:
				
				var move_horizontally: Move = Move.new(piece_position,new_position,Vector2i(-1,-1))
				availabe_moves.append(move_horizontally)
				
			else:
				
				if contents.team_is_white != piece.team_is_white:
					var kill_horizontally: Move = Move.new(piece_position,new_position,new_position)
					availabe_moves.append(kill_horizontally)
				
				break
			
			new_position += direction
	
	
	return availabe_moves
