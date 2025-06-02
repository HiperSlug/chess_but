extends Node2D
class_name Board2D

## Stores the board currently displayed.
## Not neccecarily the same board as in chess_game.
var board: Board

## Stores the current team
var turn_is_white: bool = true

## Override for if moves can be input.
## Used during promotion, when looking at history, when multiplayer other players turn, etc.
var can_input_moves: bool = true


func _ready() -> void:
	initalize_board_tiles(Board.board_length)
	Globals.on_game_end.connect(on_game_end)


func on_game_end(_result: Globals.RESULT) -> void:
	can_input_moves = false


## Connected to chess game on_turn_changed
## changes the member variable turn_is_white and rotates the board
func on_chess_game_turn_changed(new_turn_is_white: bool) -> void:
	turn_is_white = new_turn_is_white
	
	var wait_time: float = Globals.move_time * 2
	await get_tree().create_timer(wait_time).timeout
	
	if not NetworkHandler.is_in_match:
		rotate_board(turn_is_white)
	
	
	if turn_is_white:
		$CanvasLayer2/BoardPosition/Polygon2D.color = Color("#e0e0e0")
	else:
		$CanvasLayer2/BoardPosition/Polygon2D.color = Color("#504c50")
	
	

## Connected to gui elements
signal on_board_2d_rotated(team_is_white: bool)

## Variable containing current rotation of the board.
var rotated_so_bottom_team_is_white: bool = true

## Rotates the board_2d so that the bottom team is either white or black based on parameters.
## In order to achieve balance the pieces global rotation is set to zero
func rotate_board(bottom_team_is_white: bool) -> void:
	
	rotated_so_bottom_team_is_white = bottom_team_is_white
	
	on_board_2d_rotated.emit(bottom_team_is_white)
	
	if bottom_team_is_white:
		$CanvasLayer2/BoardPosition/Tiles.rotation = 0
		$CanvasLayer2/BoardPosition/Pieces.rotation = 0
		for child: Node2D in $CanvasLayer2/BoardPosition/Pieces.get_children():
			child.rotation = 0
	else:
		$CanvasLayer2/BoardPosition/Tiles.rotation = PI
		$CanvasLayer2/BoardPosition/Pieces.rotation = PI
		for child: Node2D in $CanvasLayer2/BoardPosition/Pieces.get_children():
			child.rotation = PI



#region TILES
## Packed scene containing tile
var tile_scene: PackedScene = preload("res://display_board/board_2d/tile.tscn")

## Matrix of tiles, used to lookup which nodes are at which position.
var tile_matrix: Array[Array]

## Creates a tile for every position in the matrix.
## Initalizes color, position, matrix position, and stores tile in tile_matrix.
## Connects tile pressed signals to local functions
func initalize_board_tiles(board_length: int) -> void:
	
	# resize tile matrix
	tile_matrix.resize(board_length)
	for y_array: Array in tile_matrix:
		y_array.resize(board_length)
	
	for y: int in range(board_length):
		for x: int in range(board_length):
			
			
			var tile: Tile = tile_scene.instantiate()
			
			# tile color
			var is_tile_white: bool = ((x + y) % 2 == 0)
			if is_tile_white:
				tile.set_color(Color("#eeeed2"))
			else:
				tile.set_color(Color("#769656"))
			
			# set matrix position
			tile.tile_position = Vector2i(x,y)
			
			tile_matrix[x][y] = tile
			
			# connect signals
			tile.on_tile_pressed.connect(on_tile_pressed)
			tile.on_tile_released.connect(on_tile_released)
			
			# position
			tile.position.x = Tile.tile_size * (x-4)
			tile.position.y = Tile.tile_size * (y-4)
			
			$CanvasLayer2/BoardPosition/Tiles.add_child(tile)

## Tells the tile at tile position to display the effect.
func set_tile_effect(tile_position: Vector2i, effect: Tile.TILE_EFFECT) -> void:
	tile_matrix[tile_position.x][tile_position.y].set_tile_effect(effect)

## Tells all tiles to display TILE_EFFECT.NONE
func reset_all_tile_effects() -> void:
	for array_y: Array in tile_matrix:
		for tile: Tile in array_y:
			tile.set_tile_effect(Tile.TILE_EFFECT.NONE)
#endregion


#region PIECES
## Packed scene containing base piece_2d to be linked to a piece
var piece_2d_scene: PackedScene = preload("res://display_piece/piece_2d/piece_2d.tscn")

## Iterates through the board and creates a linked piece_2d for every piece on the board.
## Should not be called if there are already piece_2ds linked to the pieces.
func setup_board_pieces() -> void:
	
	for x: int in range(board.board_length):
		for y: int in range(board.board_length):
			
			# get contents at position
			var pos: Vector2i = Vector2i(x,y)
			var contents = board.get_contents_at_position(pos)
			if contents == null:
				continue
			
			# initalize piece_2d
			var piece_2d: Piece2D = piece_2d_scene.instantiate()
			
			piece_2d.set_piece(contents)
			
			# position
			piece_2d.position.x = Tile.tile_size * (x - 3.5)
			piece_2d.position.y = Tile.tile_size * (y - 3.5)
			
			
			if not rotated_so_bottom_team_is_white:
				piece_2d.rotation = PI
			
			# signals
			board.piece_position_changed.connect(piece_2d.on_board_piece_position_changed)
			board.piece_removed.connect(piece_2d.on_board_piece_removed)
			
			$CanvasLayer2/BoardPosition/Pieces.add_child(piece_2d)

## Removes all board pieces.
func clear_board_pieces() -> void:
	for piece: Piece2D in $CanvasLayer2/BoardPosition/Pieces.get_children():
		piece.queue_free()
#endregion


#region INPUT
## Signal emitted to ChessGame after a move is input
signal on_input_move(move: Move)

## A list of all currently available moves. 
## If an input occurs on an already available move that means they are trying to complete a move.
var displayed_moves: Array[Move]

## The position that is currently selected
## (-1, -1) means no position is currently selected
var selected_position: Vector2i

## Releasing a tile will only deselect it if it had been pressed while selected.
var can_deselect_on_tile_released: bool = false

## Functions connected to tile objects.
## Checks if tile is an attempted completion of a move.
## Otherwise displays all moves available to this player at the pressed tile.
func on_tile_pressed(tile_position: Vector2i) -> void: 
	
	if not can_input_moves:
		reset_all_tile_effects()
		clear_selections()
		return
	
	# if this tile is already selected next tile released will unselect piece
	if tile_position == selected_position:
		can_deselect_on_tile_released = true
	
	
	var move_completed: bool = await is_tile_position_move_completion(tile_position)
	if move_completed:
		return
	
	
	# if there is a piece at the clicked position
	var contents = board.get_contents_at_position(tile_position)
	if contents == null:
		clear_selections()
		reset_all_tile_effects()
		return
	contents = contents as Piece
	
	# if the pieces team is the same as the turn
	var piece_team_same_as_turn: bool = contents.team_is_white == turn_is_white
	if piece_team_same_as_turn:
		
		# if were not playing local singleplayer we must also prevent inputing for the other team
		if NetworkHandler.is_in_match:
			
			var team_is_same_as_piece_team = NetworkHandler.team_is_white == contents.team_is_white
			if not team_is_same_as_piece_team:
				return
		
		reset_all_tile_effects()
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

## Functions connected to tile objects.
## Checks if this is an attempted deselection of the selected tile
## Otherwise displays all moves available to this player at the pressed tile.
func on_tile_released(tile_position: Vector2i) -> void:
	
	if not can_input_moves:
		reset_all_tile_effects()
		clear_selections()
		return
	
	if tile_position == selected_position:
		if can_deselect_on_tile_released:
			
			reset_all_tile_effects()
			clear_selections()
			can_deselect_on_tile_released = false
		
		return
	
	
	
	var move_completed: bool = await is_tile_position_move_completion(tile_position)
	if move_completed:
		return
	
	
	clear_selections()

## When given an array of moves that all end on the same final position, it chooses the best one.
## If a move has a secondary move embedded (castling) that is prioritized
## If a move has a kill position (enpassant) that is prioritized
## If there are multiple with the same attributes a random one is chosen
## If there are no priorities a random one is chosen.
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

## When taking an tile position it sees if any currently displayed moves end at that position\
## if they do then this function completes the best one.
func is_tile_position_move_completion(tile_position: Vector2i) -> bool:
	# get all moves that end at selected tile
	var matching_moves: Array[Move] = []
	for move: Move in displayed_moves:
		if move.final_position == tile_position:
			matching_moves.append(move) 
	
	# if there is any matching_moves
	if matching_moves.size() > 0:
		
		var best_move: Move = choose_best_move(matching_moves)
		
		await check_move_for_promotion(best_move)
		
		on_input_move.emit(best_move)
		reset_all_tile_effects()
		clear_selections()
		return true
	
	return false

## Resets all variables associated with currently displayed and selected tiles
func clear_selections() -> void:
	selected_position = Vector2i(-1, -1)
	displayed_moves = []
	can_deselect_on_tile_released = false


var promotion_dialoge_scene: PackedScene = preload("res://popups/promotion/promotion_popup.tscn")
func check_move_for_promotion(move: Move) -> void:
	
	if move.do_promotion:
		
		can_input_moves = false
		
		# position
		var promotion_dialoge_position: Vector2 = Vector2.ZERO
		
		
		
		if rotated_so_bottom_team_is_white:
			
			var spawn_to_the_right: bool = move.final_position.x < 4
			
			if spawn_to_the_right:
				promotion_dialoge_position.x = Tile.tile_size * (move.final_position.x + 1 - 4)
			
			else:
				promotion_dialoge_position.x = Tile.tile_size * (move.final_position.x - 4 - 4)
			
			promotion_dialoge_position.y = Tile.tile_size * (move.final_position.y - 4)
		
		
		else:
			
			var spawn_to_the_right: bool = move.final_position.x > 3
			
			if spawn_to_the_right:
				promotion_dialoge_position.x = Tile.tile_size * (7 + 1 - 4 - move.final_position.x)
			
			else:
				promotion_dialoge_position.x = Tile.tile_size * (7 - 4 - 4 - move.final_position.x)
			
			promotion_dialoge_position.y = Tile.tile_size * (7 - 4 - move.final_position.y)
		
		
		var promotion_dialoge: Node = promotion_dialoge_scene.instantiate()
		
		promotion_dialoge.position = promotion_dialoge_position
		add_child(promotion_dialoge)
		
		var chosen_move_set_type: Globals.TYPE = await promotion_dialoge.move_set_chosen
		promotion_dialoge.queue_free()
		
		move.promotion_type = chosen_move_set_type
		
		can_input_moves = true

#endregion
