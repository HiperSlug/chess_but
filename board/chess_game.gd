extends Control


var board: Board = Board.new()

func _ready() -> void:
	board.current_board_matrix[1][3] = create_piece(Piece.TYPE.PAWN, false, PawnMoveSet.new(false))
	board.current_board_matrix[2][5] = create_piece(Piece.TYPE.PAWN, true, PawnMoveSet.new(true))
	update_visuals()

var active_moves: Array[Move]
func on_tile_clicked(tile_position: Vector2i) -> void: # connected to each tile
	$VisualBoard.reset_all_tile_effects()
	
	if active_moves != null:
		for move: Move in active_moves:
			if move.new_position == tile_position:
				do_move(move)
				active_moves = []
				return
	
	var contents = board.current_board_matrix[tile_position.x][tile_position.y]
	if contents == null:
		active_moves = []
		return
	
	$VisualBoard.set_tile_effect(tile_position, Tile.TILE_EFFECT.SELECTED)
	
	var availabe_moves: Array[Move] = get_all_moves_at_piece(tile_position)
	for move: Move in availabe_moves:
		var end_position: Vector2i = move.new_position
		
		if move.kill_position != Vector2i(-1,-1):
			$VisualBoard.set_tile_effect(end_position,Tile.TILE_EFFECT.CAPTURE)
		else:
			$VisualBoard.set_tile_effect(end_position,Tile.TILE_EFFECT.MOVE)
	
	active_moves = availabe_moves

func do_move(move: Move) -> void:
	board.do_move(move)
	update_visuals()

func update_visuals() -> void:
	for y: int in range(board.length):
		for x: int in range(board.length):
			var piece = board.current_board_matrix[x][y]
			if piece == null:
				continue
			
			var tile_size: int = ($VisualBoard.size.x / float(board.length))
			var offset_index_position: Vector2 = Vector2i(x - 4, y - 4)
			
			var correct_visual_position: Vector2 = (offset_index_position * tile_size)
			
			piece.position = correct_visual_position

var piece_scene: PackedScene = preload("res://pieces/piece.tscn")
func create_piece(type: Piece.TYPE, team_is_white: bool, base_move_set: MoveSet) -> Piece:
	var piece: Piece = piece_scene.instantiate()
	piece.type = type
	piece.team_is_white = team_is_white
	piece.move_sets.append(base_move_set)
	
	$Pieces.add_child(piece)
	return piece

func get_all_moves_at_piece(piece_position: Vector2i):
	
	var piece = board.current_board_matrix[piece_position.x][piece_position.y]
	if piece == null:
		return
	
	var moves: Array[Move] = piece.get_all_available_moves(board, piece_position)
	
	return moves


#func print_board_for_prototyping() -> void:
	#for y in range(board_length):
		#var line: String = ""
		#for x in range(board_length):
			#var tile_value = board_matrix[x][y]
			#if tile_value == null:
				#line += " _ "
			#if tile_value is Piece:
				#var piece_str: String
				#match tile_value.type:
					#Piece.TYPE.PAWN:
						#piece_str = " P "
					#Piece.TYPE.KNIGHT:
						#piece_str = " K "
					#Piece.TYPE.BISHOP:
						#piece_str = " B "
					#Piece.TYPE.QUEEN:
						#piece_str = " Q "
					#Piece.TYPE.ROOK:
						#piece_str = " R "
					#Piece.TYPE.KING:
						#piece_str = " K "
				#if tile_value.team_is_white:
					#piece_str = piece_str.to_lower()
				#line += piece_str
		#print(line)
