extends Node2D
class_name Board2D

func set_tile_effect(tile_position: Vector2i, effect: Tile.TILE_EFFECT) -> void:
	tile_array[tile_position.x][tile_position.y].set_tile_effect(effect)

func reset_all_tile_effects() -> void:
	for array_y: Array in tile_array:
		for tile: Tile in array_y:
			tile.set_tile_effect(Tile.TILE_EFFECT.NONE)

func initalize_board(board: Board) -> void: # called by ChessGame
	initalize_board_tiles(board.length)
	initalize_board_peices(board)

var tile_scene: PackedScene = preload("res://board/board_2d/tile.tscn")
var tile_array: Array[Array]
func initalize_board_tiles(board_length: int) -> void:
	
	tile_array.resize(board_length)
	for y_array: Array in tile_array:
		y_array.resize(board_length)
	
	for y: int in range(board_length):
		for x: int in range(board_length):
			
			var tile: Tile = tile_scene.instantiate()
	
			var is_tile_white: bool = ((x + y) % 2 == 0)
			if is_tile_white:
				tile.set_color(Color.WHITE)
			else:
				tile.set_color(Color.BLANCHED_ALMOND)
			
			tile.tile_position = Vector2i(x,y)
			if not Engine.is_editor_hint():
				tile.on_tile_clicked.connect(on_tile_clicked)
			tile_array[x][y] = tile
			
			tile.position.x = Tile.tile_size * (x-4)
			tile.position.y = Tile.tile_size * (y-4)
			add_child(tile)

var id_to_piece_2d_dictionary: Dictionary
var piece_2d_scene: PackedScene = preload("res://pieces/piece_2d/piece_2d.tscn")
func initalize_board_peices(board: Board) -> void:
	for x: int in range(board.length):
		for y: int in range(board.length):
			
			# if piece exists
			var piece = board.current_board_matrix[x][y]
			if piece == null:
				continue
			piece = piece as Piece
			
			var piece_2d: Piece2D = piece_2d_scene.instantiate()
			
			# copy display relevant info onto piece
			piece_2d.team_is_white = piece.team_is_white
			piece_2d.type = piece.type
			piece_2d.position.x = Tile.tile_size * (x - 4)
			piece_2d.position.y = Tile.tile_size * (y - 4)
			
			piece_2d.displayed_move_sets = piece.move_sets
			
			
			# store refrence to piece
			id_to_piece_2d_dictionary[piece.piece_id] = piece_2d
			
			add_child(piece_2d)

func update_pieces(move: Move) -> void:
	
	if move.killed_piece_id != -1:
		var killed_piece: Piece2D = id_to_piece_2d_dictionary[move.killed_piece_id]
		killed_piece.queue_free()
	
	var moved_piece: Piece2D = id_to_piece_2d_dictionary[move.moved_piece_id]
	
	moved_piece.position.x = Tile.tile_size * (move.final_position.x - 4)
	moved_piece.position.y = Tile.tile_size * (move.final_position.y - 4)


signal move_completed(move: Move)
var active_moves: Array[Move]
func on_tile_clicked(tile_position: Vector2i) -> void: 
	
	reset_all_tile_effects()
	
	# check if an already active tile has been clicked
	var matching_moves: Array[Move] = []
	for move: Move in active_moves:
		if move.final_position == tile_position:
			matching_moves.append(move) 
			
	if not matching_moves.size() == 0:
		if matching_moves.size() == 1:
			move_completed.emit(matching_moves[0])
			active_moves = []
			return
		else:
			print("competition")
			move_completed.emit(matching_moves[0])
			active_moves = []
			return
	
	if not $"..".does_piece_exist(tile_position):
		active_moves = []
		return
	
	
	var availabe_moves = $"..".get_all_moves_at_position(tile_position)
	
	# set tile effects
	set_tile_effect(tile_position, Tile.TILE_EFFECT.SELECTED)
	
	for move: Move in availabe_moves:
		var end_position: Vector2i = move.final_position
		
		if move.kill_position != Vector2i(-1,-1):
			set_tile_effect(end_position,Tile.TILE_EFFECT.CAPTURE)
		else:
			set_tile_effect(end_position,Tile.TILE_EFFECT.MOVE)
	
	# store moves
	active_moves = availabe_moves
