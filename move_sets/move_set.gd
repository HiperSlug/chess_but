extends RefCounted
class_name MoveSet

var team_is_white: bool
var type: Globals.TYPE
var chess_game: ChessGame

func _init(_type: Globals.TYPE, _chess_game: ChessGame, _team_is_white: bool = true) -> void:
	self.chess_game = _chess_game
	self.type = _type
	self.team_is_white = _team_is_white

func get_all_available_moves(board: Board, piece_position: Vector2i, piece_team_is_white: bool, total_move_count: int = 0, do_king_safety_check = true) -> Array[Move]:
	
	var available_moves: Array[Move] = []
	
	match type:
		Globals.TYPE.PAWN:
			var type_pawn: Array[Move] = get_pawn_available_moves(board, piece_position, piece_team_is_white, total_move_count, do_king_safety_check)
			available_moves = type_pawn
			
		Globals.TYPE.KNIGHT:
			var type_knight: Array[Move] = get_knight_available_moves(board, piece_position, piece_team_is_white, total_move_count, do_king_safety_check)
			available_moves = type_knight
			
		Globals.TYPE.BISHOP:
			var type_bishop: Array[Move] = get_diagonal_available_moves(board, piece_position, piece_team_is_white, total_move_count, do_king_safety_check)
			available_moves = type_bishop
			
		Globals.TYPE.ROOK:
			var type_rook: Array[Move] = get_horizontal_and_vertical_available_moves(board, piece_position, piece_team_is_white, total_move_count, do_king_safety_check)
			available_moves = type_rook
			
		Globals.TYPE.QUEEN:
			var horizontal_and_vertical: Array[Move] = get_horizontal_and_vertical_available_moves(board, piece_position, piece_team_is_white, total_move_count, do_king_safety_check)
			var diagonal: Array[Move] = get_diagonal_available_moves(board, piece_position, piece_team_is_white, total_move_count, do_king_safety_check)
			var type_queen: Array[Move] = []
			type_queen.append_array(horizontal_and_vertical)
			type_queen.append_array(diagonal)
			available_moves = type_queen
			
		Globals.TYPE.KING:
			var type_king: Array[Move] = get_king_available_moves(board, piece_position, piece_team_is_white, total_move_count, do_king_safety_check)
			available_moves = type_king
			
	
	return available_moves


func is_in_bounds(position: Vector2i, board: Board) -> bool:
	var x_in_bounds: bool = position.x < board.board_length and position.x >= 0
	var y_in_bounds: bool = position.y < board.board_length and position.y >= 0
	return x_in_bounds and y_in_bounds


func get_pawn_available_moves(board: Board, piece_position: Vector2i, piece_team_is_white: bool, total_move_count: int = 0, do_king_safety_check = true) -> Array[Move]:
	
	var available_moves: Array[Move]
	
	var forward_direction: Vector2i
	if team_is_white:
		forward_direction = Vector2i.UP
	else:
		forward_direction = Vector2i.DOWN
	
	
	# move forward one
	
	# is in bounds
	var forward_one_position: Vector2i = piece_position + forward_direction
	if is_in_bounds(forward_one_position, board):
		
		# is empty
		var contents_forward_one_position = board.get_contents_at_position(forward_one_position)
		if contents_forward_one_position == null:
			
			# add move forward one as available move
			var move_forward_one: Move = Move.new(piece_position, forward_one_position)
			
			# king safety check
			if do_king_safety_check:
				if not board.would_king_be_in_check_after_move(move_forward_one, piece_team_is_white):
					available_moves.append(move_forward_one)
			
			else:
				available_moves.append(move_forward_one)
			
			# move forward two
			
			# first time this pawn has moved
			if total_move_count == 0:
				
				# is in bounds
				var forward_two_position: Vector2i = piece_position + (forward_direction * 2)
				if is_in_bounds(forward_two_position, board):
					
					# is empty
					var contents_forward_two_positions = board.get_contents_at_position(forward_two_position)
					if contents_forward_two_positions == null:
						
						# add move forward two as available move
						var move_forward_two: Move = Move.new(piece_position, forward_two_position)
						
						# king safety check
						if do_king_safety_check:
							if not board.would_king_be_in_check_after_move(move_forward_two, piece_team_is_white):
								available_moves.append(move_forward_two)
						
						else:
							available_moves.append(move_forward_two)
	
	
	# diagonally attack
	var diagonal_positions: Array[Vector2i] = [
		forward_direction + Vector2i.LEFT + piece_position,
		forward_direction + Vector2i.RIGHT + piece_position,
	]
	
	for diagonal_position: Vector2i in diagonal_positions:
		# is in bounds
		if is_in_bounds(diagonal_position, board):
			
			# is occupied
			var contents_diagonal = board.get_contents_at_position(diagonal_position)
			if contents_diagonal != null:
				
				# is occupied by enemy
				var piece_is_enemey: bool = (contents_diagonal.team_is_white == not piece_team_is_white)
				if piece_is_enemey:
					
					# add valid move
					var capture_diagonally: Move = Move.new(piece_position, diagonal_position, diagonal_position)
					# check for king safety
					if do_king_safety_check:
						if not board.would_king_be_in_check_after_move(capture_diagonally, piece_team_is_white):
							available_moves.append(capture_diagonally)
							
					else:
						available_moves.append(capture_diagonally)
			
			# en passant
			else: # if diagonal contents are empty
				
				var adjacent_position: Vector2i = diagonal_position - forward_direction
				var contents_adjacent = board.get_contents_at_position(adjacent_position)
				# is occupied
				if contents_adjacent != null:
					 
					# by enemy pawn
					var is_pawn: bool = (contents_adjacent.type == Globals.TYPE.PAWN)
					var is_enemy: bool = (contents_adjacent.team_is_white == not piece_team_is_white)
					if is_pawn and is_enemy:
						
						# the enemy pawn moved last turn
						var last_move: Move = chess_game.get_last_move() 
						if last_move.final_position == adjacent_position:
							
							# the enemy pawn had done double time last turn
							var change_in_position: int = last_move.final_position.y - last_move.inital_position.y
							var pawn_did_double_time_last_move: bool = (abs(change_in_position) == 2)
							if pawn_did_double_time_last_move:
								
								# add valid move to available moves
								var en_passant: Move = Move.new(piece_position, diagonal_position, adjacent_position)
								# king safety check
								if do_king_safety_check:
									if not board.would_king_be_in_check_after_move(en_passant, piece_team_is_white):
										available_moves.append(en_passant)
								else:
									available_moves.append(en_passant)
	
	
	
	return available_moves

func get_knight_available_moves(board: Board, piece_position: Vector2i, piece_team_is_white: bool, _total_move_count: int = 0, do_king_safety_check = true) -> Array[Move]:
	
	var availabe_moves: Array[Move]
	
	var radial_positions: Array[Vector2i] = [
		Vector2i(2,-1),
		Vector2i(2,1),
		Vector2i(1,2),
		Vector2i(-1,2),
		Vector2i(-2,1),
		Vector2i(-2,-1),
		Vector2i(-1,-2),
		Vector2i(1,-2),
	]
	
	
	for position: Vector2i in radial_positions:
		
		# is in bounds
		var new_position: Vector2i = piece_position + position
		if is_in_bounds(new_position, board): 
			
			# if empty: move
			var radial_contents = board.get_contents_at_position(new_position)
			if radial_contents == null:
				
				# add move to available moves
				var move_radially: Move = Move.new(piece_position, new_position)
				# king safety check
				if do_king_safety_check:
					if not board.would_king_be_in_check_after_move(move_radially, piece_team_is_white):
						availabe_moves.append(move_radially)
				else:
					availabe_moves.append(move_radially)
				
			# if enemy piece: capture
			elif radial_contents.team_is_white != piece_team_is_white:
					
					# add kill radially to avaiable moves
					var kill_radially: Move = Move.new(piece_position, new_position, new_position)
					# king safety check
					if do_king_safety_check:
						if not board.would_king_be_in_check_after_move(kill_radially, piece_team_is_white):
							availabe_moves.append(kill_radially)
					else:
						availabe_moves.append(kill_radially)
	
	return availabe_moves

func get_king_available_moves(board: Board, piece_position: Vector2i, piece_team_is_white: bool, total_move_count: int = 0, do_king_safety_check = true) -> Array[Move]:
	var availabe_moves: Array[Move]
	
	var king_positions: Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i(1,1),
		Vector2i(1,-1),
		Vector2i(-1,-1),
		Vector2i(-1,1),
	]
	
	# checking normal king moves
	for position: Vector2i in king_positions:
		
		# is in bounds
		var new_position: Vector2i = piece_position + position
		if is_in_bounds(new_position, board):
			
			# if is empty: move
			var contents = board.get_contents_at_position(new_position)
			if contents == null:
				
				# add possible move
				var move_horizontally: Move = Move.new(piece_position, new_position)
				# king safety check
				if do_king_safety_check:
					if not board.would_king_be_in_check_after_move(move_horizontally, piece_team_is_white):
						availabe_moves.append(move_horizontally)
				else:
					availabe_moves.append(move_horizontally)
			
			# is enemy team: capture
			elif contents.team_is_white != piece_team_is_white:
				
				# add possible move
				var kill_horizontally: Move = Move.new(piece_position,new_position,new_position)
				# king safety check
				if do_king_safety_check:
					if not board.would_king_be_in_check_after_move(kill_horizontally,piece_team_is_white):
						availabe_moves.append(kill_horizontally)
				else:
					availabe_moves.append(kill_horizontally)
		
	# castling
	var caslting_directions: Array[Vector2i] = [
		Vector2i.RIGHT,
		Vector2i.LEFT,
	]
	
	# if first king move
	if total_move_count == 0:
		
		for direction: Vector2i in caslting_directions:
			
			# path clear
			
			# iterating till the last tile of the board, or until it hits a piece
			var new_position: Vector2i = piece_position + direction
			var path_clear: bool = true
			while is_in_bounds(new_position + direction, board): # "+ direction" stops it one short of the edge of the board allowing for an extra piece (hopefully which is a rook)
				
				# checking for collision
				var contents = board.get_contents_at_position(new_position)
				if contents != null:
					# collision: castling not possible
					path_clear = false
					break
				
				# iterate
				new_position += direction
			
			# try other direction
			if not path_clear:
				continue
			
			# rook at end
			
			var rook_position: Vector2i = new_position # lol
			
			# if there is a piece there
			if is_in_bounds(rook_position, board):
				var piece_at_rook_position = board.get_contents_at_position(rook_position)
				if piece_at_rook_position != null:
					
					# and the piece is a rook on our team who hasnt moved
					var piece_is_rook: bool = piece_at_rook_position.type == Globals.TYPE.ROOK
					var piece_is_same_team: bool = piece_at_rook_position.team_is_white == piece_team_is_white
					var is_rooks_first_move: bool = piece_at_rook_position.total_move_count == 0
					if piece_is_rook and piece_is_same_team and is_rooks_first_move:
							
							var one_towards_direction: Vector2i = piece_position + direction
							var two_towards_direction: Vector2i = piece_position + (direction * 2)
							
							# we need to check if the king is under attack, the inbetween position is under attack, and if the final position is under attack
							var rook_move: Move = Move.new(rook_position, one_towards_direction)
							var castle_move: Move = Move.new(piece_position, two_towards_direction, Vector2i(-1, -1), rook_move)
							# king safety check
							if do_king_safety_check:
								
								# king currently under attack
								var currently_under_attack: bool = board.is_piece_at_position_being_attacked(piece_position)
								
								# inbetween position under attack
								var inbetween_move: Move = Move.new(piece_position, one_towards_direction)
								var inbetween_move_under_attack: bool = board.would_king_be_in_check_after_move(inbetween_move, piece_team_is_white)
								
								# final position under attack
								var final_move_under_attack: bool = board.would_king_be_in_check_after_move(castle_move, piece_team_is_white)
								
								# add final move
								if not currently_under_attack and not inbetween_move_under_attack and not final_move_under_attack:
									availabe_moves.append(castle_move)
							else:
								availabe_moves.append(castle_move)
	
	return availabe_moves

func get_horizontal_and_vertical_available_moves(board: Board, piece_position: Vector2i, piece_team_is_white: bool, _total_move_count: int = 0, do_king_safety_check = true) -> Array[Move]: 
	
	var availabe_moves: Array[Move]
	
	var directions: Array[Vector2i] = [
		Vector2i.UP,
		Vector2i.DOWN,
		Vector2i.LEFT,
		Vector2i.RIGHT,
	]
	
	for direction: Vector2i in directions:
		
		# iterating towards direction till it hits the boundary or is broken out by hitting another piece
		var new_position: Vector2i = piece_position + direction
		while is_in_bounds(new_position, board): 
			
			# if its empty: move
			var contents_in_direction = board.get_contents_at_position(new_position)
			if contents_in_direction == null:
				
				# add move horizontally to pool of moves
				var move_horizontally: Move = Move.new(piece_position, new_position)
				# king safety check
				if do_king_safety_check:
					
					if not board.would_king_be_in_check_after_move(move_horizontally, piece_team_is_white):
						
						availabe_moves.append(move_horizontally)
					
					
				else:
					availabe_moves.append(move_horizontally)
				
			else:
				
				# if the position has an enemy piece: capture
				if contents_in_direction.team_is_white != piece_team_is_white:
					
					var kill_horizontally: Move = Move.new(piece_position, new_position, new_position)
					# king safety check
					if do_king_safety_check:
						if not board.would_king_be_in_check_after_move(kill_horizontally, piece_team_is_white):
							availabe_moves.append(kill_horizontally)
							
					else:
						availabe_moves.append(kill_horizontally)
						
				# if it runs into any piece break out of the loop
				break
			
			# iterate towards direction
			new_position += direction
	
	
	return availabe_moves

func get_diagonal_available_moves(board: Board, piece_position: Vector2i, piece_team_is_white: bool, _total_move_count: int = 0, do_king_safety_check = true) -> Array[Move]:
	var availabe_moves: Array[Move]
	
	var directions: Array[Vector2i] = [
		Vector2i(1,1),
		Vector2i(1,-1),
		Vector2i(-1,-1),
		Vector2i(-1,1),
	]
	
	for direction: Vector2i in directions:
		
		# iterating towards direction till it hits the boundary or is broken out by hitting another piece
		var new_position: Vector2i = piece_position + direction
		while is_in_bounds(new_position, board): 
			
			# if its empty: move
			var contents_in_direction = board.get_contents_at_position(new_position)
			if contents_in_direction == null:
				
				# add move diagonally to pool of moves
				var move_diagonally: Move = Move.new(piece_position, new_position, Vector2i(-1,-1))
				# king safety check
				if do_king_safety_check:
					if not board.would_king_be_in_check_after_move(move_diagonally, piece_team_is_white):
						availabe_moves.append(move_diagonally)
						
				else:
					availabe_moves.append(move_diagonally)
				
			else:
				
				# if the position has an enemy piece: capture
				if contents_in_direction.team_is_white != piece_team_is_white:
					
					var kill_diagonally: Move = Move.new(piece_position, new_position, new_position)
					# king safety check
					if do_king_safety_check:
						if not board.would_king_be_in_check_after_move(kill_diagonally, piece_team_is_white):
							availabe_moves.append(kill_diagonally)
							
					else:
						availabe_moves.append(kill_diagonally)
						
				# if it runs into any piece break out of the loop
				break
			
			# iterate towards direction
			new_position += direction
	
	
	return availabe_moves
