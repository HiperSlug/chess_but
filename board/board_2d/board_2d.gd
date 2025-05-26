extends Node2D
class_name Board2D

var board: Board

func set_tile_effect(tile_position: Vector2i, effect: Tile.TILE_EFFECT) -> void:
	tile_array[tile_position.x][tile_position.y].set_tile_effect(effect)

func reset_all_tile_effects() -> void:
	for array_y: Array in tile_array:
		for tile: Tile in array_y:
			tile.set_tile_effect(Tile.TILE_EFFECT.NONE)

func initalize_board(_board: Board) -> void: # called by ChessGame
	board = _board
	input_move.connect(board.complete_move)
	board.promotion.connect(on_pawn_promote)
	initalize_board_tiles(Globals.board_length)
	initalize_board_peices()

var promotion_popup_scene: PackedScene = preload("res://popups/promotion_popup.tscn")
func on_pawn_promote(piece: Piece) -> void:
	var promotion_popup: Node = promotion_popup_scene.instantiate()
	
	add_child(promotion_popup)
	await promotion_popup.move_set_chosen
	
	for move_set: MoveSet in piece.move_sets:
		if move_set.team_is_white == piece.team_is_white:
			if move_set.type == piece.type:
				
				piece.remove_move_set(move_set)
				break
	
	var chosen_move_set: MoveSet = promotion_popup.chosen_move_set
	piece.add_move_set(chosen_move_set)
	piece.type = chosen_move_set.type
	promotion_popup.queue_free()


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
				tile.on_tile_pressed.connect(on_tile_pressed)
				tile.on_tile_released.connect(on_tile_released)
			tile_array[x][y] = tile
			
			tile.position.x = Tile.tile_size * (x-4)
			tile.position.y = Tile.tile_size * (y-4)
			add_child(tile)

var id_to_piece_2d_dictionary: Dictionary
var piece_2d_scene: PackedScene = preload("res://pieces/piece_2d/piece_2d.tscn")
func initalize_board_peices() -> void:
	for x: int in range(Globals.board_length):
		for y: int in range(Globals.board_length):
			
			# if piece exists
			var piece = board.current_board_matrix[x][y]
			if piece == null:
				continue
			
			var piece_2d: Piece2D = piece_2d_scene.instantiate()
			
			piece_2d.set_piece(piece)
			
			piece_2d.position.x = Tile.tile_size * (x - 4)
			piece_2d.position.y = Tile.tile_size * (y - 4)
			
			board.piece_position_changed.connect(piece_2d.on_board_piece_position_changed)
			board.piece_removed.connect(piece_2d.on_board_piece_removed)
			
			add_child(piece_2d)

signal input_move(move: Move)
var displayed_moves: Array[Move]
var selected_position

var can_deselect: bool = false

func on_tile_pressed(tile_position: Vector2i) -> void: 
	reset_all_tile_effects()
	
	if tile_position == selected_position:
		can_deselect = true
	
	var matching_moves: Array[Move] = []
	for move: Move in displayed_moves:
		if move.final_position == tile_position:
			matching_moves.append(move) 
			
	if not matching_moves.size() == 0:
		if matching_moves.size() == 1:
			input_move.emit(matching_moves[0])
			deselect_all()
			return
		else:
			var all_equal: bool = true
			var last_move: Move = matching_moves[0]
			for move: Move in matching_moves:
				if not move.equals(last_move):
					print("competing moves")
					input_move.emit(matching_moves[0])
					deselect_all()
					return
			input_move.emit(matching_moves[0])
			deselect_all()
			return
	
	
	var availabe_moves = board.get_availabe_moves_at_position(tile_position)
	
	# set tile effects
	set_tile_effect(tile_position, Tile.TILE_EFFECT.SELECTED)
	selected_position = tile_position
	
	for move: Move in availabe_moves:
		var end_position: Vector2i = move.final_position
		
		if move.kill_position != Vector2i(-1,-1):
			set_tile_effect(end_position,Tile.TILE_EFFECT.CAPTURE)
		else:
			set_tile_effect(end_position,Tile.TILE_EFFECT.MOVE)
	
	# store moves
	displayed_moves = availabe_moves
	
	

func on_tile_released(tile_position: Vector2i) -> void:
	
	if tile_position == selected_position:
		if can_deselect:
			reset_all_tile_effects()
			deselect_all()
			can_deselect = false
		return
		
	reset_all_tile_effects()
	
	var matching_moves: Array[Move] = []
	for move: Move in displayed_moves:
		if move.final_position == tile_position:
			matching_moves.append(move) 
			
	if not matching_moves.size() == 0:
		if matching_moves.size() == 1:
			input_move.emit(matching_moves[0])
			deselect_all()
			return
		else:
			var all_equal: bool = true
			var last_move: Move = matching_moves[0]
			for move: Move in matching_moves:
				if not move.equals(last_move):
					print("competing Moves")
					input_move.emit(matching_moves[0])
					deselect_all()
					return
			
			
			input_move.emit(matching_moves[0])
			deselect_all()
			return
	
	
	deselect_all()


func deselect_all() -> void:
	selected_position = null
	displayed_moves = []
	can_deselect = false
