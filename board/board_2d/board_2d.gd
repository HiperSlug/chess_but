extends Node2D
class_name Board2D

var board: Board

var turn_is_white: bool = true

var team_is_white: bool = true



func set_turn(_turn_is_white: bool) -> void:
	turn_is_white = _turn_is_white
	if not NetworkHandler.is_in_match:
		team_is_white = turn_is_white
		await get_tree().create_timer(Globals.move_time * 2).timeout
		rotate_board(team_is_white)

func set_tile_effect(tile_position: Vector2i, effect: Tile.TILE_EFFECT) -> void:
	tile_array[tile_position.x][tile_position.y].set_tile_effect(effect)

func reset_all_tile_effects() -> void:
	for array_y: Array in tile_array:
		for tile: Tile in array_y:
			tile.set_tile_effect(Tile.TILE_EFFECT.NONE)

func initalize_board(_board: Board) -> void: # called by ChessGame
	board = _board
	
	initalize_board_tiles(board.board_length)
	initalize_board_peices()
	
	var game_gui: Control = load("res://gui/game_gui.tscn").instantiate()
	$CanvasLayer.add_child(game_gui)


func _ready() -> void:
	Globals.on_input_tells_board_rotate.connect(rotate_board)

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
	for x: int in range(board.board_length):
		for y: int in range(board.board_length):
			
			# if piece exists
			var piece = board.current_board_matrix[x][y]
			if piece == null:
				continue
			
			var piece_2d: Piece2D = piece_2d_scene.instantiate()
			
			piece_2d.set_piece(piece)
			
			piece_2d.position.x = Tile.tile_size * (x - 3.5)
			piece_2d.position.y = Tile.tile_size * (y - 3.5)
			
			board.piece_position_changed.connect(piece_2d.on_board_piece_position_changed)
			board.piece_removed.connect(piece_2d.on_board_piece_removed)
			
			
			$Pieces.add_child(piece_2d)

func rotate_board(_team_is_white: bool) -> void:
	Globals.on_board_rotated.emit(_team_is_white)
	if _team_is_white:
		rotation = 0
		for child: Node2D in $Pieces.get_children():
			child.rotation = 0
	else:
		rotation = PI
		for child: Node2D in $Pieces.get_children():
			child.rotation = PI

signal input_move(move: Move)
var displayed_moves: Array[Move]
var selected_position

var can_deselect: bool = false

func on_tile_pressed(tile_position: Vector2i) -> void: 
	reset_all_tile_effects()
	
	
	# if this tile is already selected next tile released will unselect piece
	if tile_position == selected_position:
		can_deselect = true
	
	else:
		# otherwise figure out if the pressed tile is one that is currently availabel to move to.
		
		# get all moves that end at selected tile
		var matching_moves: Array[Move] = []
		for move: Move in displayed_moves:
			if move.final_position == tile_position:
				matching_moves.append(move) 
		
		# if there is at least 1 move that matches then an action has been taken
		if not matching_moves.size() == 0:
			
			# if there is only one move, do the action
			if matching_moves.size() == 1:
				input_move.emit(matching_moves[0])
				deselect_all()
				return
			# if there is more than one move and they are different, then use magic randomness to choose the best one.
			else:
				var last_move: Move = matching_moves[0]
				var all_equal: bool = true
				for move: Move in matching_moves:
					if not move.equals(last_move):
						all_equal = false
						break
				
				# they are all the same
				if all_equal:
					input_move.emit(matching_moves[0])
					deselect_all()
					return
				
				else:
					var best_moves: Move = choose_best_move(matching_moves)
					input_move.emit(best_moves)
					deselect_all()
					return
	
	# we have now decided we are not completing an action.
	
	
	# set tile effects
	
	
	
	
	# if it's this teams turn then do a move
	var is_teams_turn: bool = board.get_contents_at_position(tile_position) != null and board.get_team_at_position(tile_position) == turn_is_white
	
	if is_teams_turn:
		var team_is_our_team: bool = not NetworkHandler.is_in_match or NetworkHandler.team_is_white == board.get_team_at_position(tile_position)
		
		if team_is_our_team: 
			set_tile_effect(tile_position, Tile.TILE_EFFECT.SELECTED)
			selected_position = tile_position
			
			# display available moves
			var availabe_moves = board.get_availabe_moves_at_position(tile_position)
			
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
		# if we arent deselecting, aka we just clicked on the piece and let go, then dont do stuff.
		return
	
	
	reset_all_tile_effects()
	
	# get all moves that end at selected tile
	var matching_moves: Array[Move] = []
	for move: Move in displayed_moves:
		if move.final_position == tile_position:
			matching_moves.append(move) 
	
	# if there is at least 1 move that matches then an action has been taken
	if not matching_moves.size() == 0:
		
		# if there is only one move, do the action
		if matching_moves.size() == 1:
			input_move.emit(matching_moves[0])
			deselect_all()
			return
		# if there is more than one move and they are different, then add a popup to select which move to do.
		else:
			var last_move: Move = matching_moves[0]
			var all_equal: bool = true
			for move: Move in matching_moves:
				if not move.equals(last_move):
					all_equal = false
					break
			
			# they are all the same
			if all_equal:
				input_move.emit(matching_moves[0])
				deselect_all()
				return
			
			else:
				var best_moves: Move = choose_best_move(matching_moves)
				input_move.emit(best_moves)
				deselect_all()
				return
	
	
	deselect_all()


func choose_best_move(moves: Array[Move]) -> Move:
	var moves_with_secondary: Array[Move]
	var moves_with_kill: Array[Move]
	
	for move: Move in moves:
		if move.kill_position != Vector2i(-1,-1):
			moves_with_kill.append(move)
		if move.secondary_move != null:
			moves_with_secondary.append(move)
	
	if moves_with_secondary.size() > 0:
		return moves_with_secondary.pick_random()
	if moves_with_kill.size() > 0:
		return moves_with_kill.pick_random()
	else:
		return moves.pick_random()

func deselect_all() -> void:
	selected_position = null
	displayed_moves = []
	can_deselect = false
