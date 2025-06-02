extends Node
class_name ChessGame



func connect_to_history_signals() -> void:
	#Globals.on_history_back_pressed.connect(hisotry_back)
	#Globals.on_history_current_pressed.connect(history_current)
	#Globals.on_history_first_pressed.connect(history_first)
	#Globals.on_history_forward_pressed.connect(history_forward)
	pass


var in_history_mode: bool = false
var history_rotation_team_is_white: bool = true
var history_position: int = 0

func hisotry_back() -> void:
	enter_history_mode(board_history.size())
	history_position -= 1
	if history_position < 0:
		return
	else:
		Globals.on_hisotry_position_set.emit(history_position)
		board_2d_node.clear_pieces_from_board()
		board_2d_node.board = board_history[history_position]
		board_2d_node.initalize_board_peices()

func history_forward() -> void:
	history_position += 1
	if history_position >= board_history.size():
		exit_history_mode()
	else:
		Globals.on_hisotry_position_set.emit(history_position)
		board_2d_node.clear_pieces_from_board()
		board_2d_node.board = board_history[history_position]
		board_2d_node.initalize_board_peices()

func history_current() -> void:
	history_position = board_history.size()
	exit_history_mode()

func history_first() -> void:
	enter_history_mode(0)
	
	history_position = 0
	Globals.on_hisotry_position_set.emit(history_position)
	board_2d_node.clear_pieces_from_board()
	board_2d_node.board = board_history[history_position]
	board_2d_node.initalize_board_peices()

func enter_history_mode(_history_pos) -> void:
	if in_history_mode:
		return
	
	Globals.on_hisotry_mode_set.emit(true)
	board_2d_node.reset_all_tile_effects()
	board_2d_node.deselect_all()
	board_2d_node.can_select_any_thing = false
	in_history_mode = true
	history_position = _history_pos

func exit_history_mode() -> void:
	in_history_mode = false
	Globals.on_hisotry_position_set.emit(history_position)
	Globals.on_hisotry_mode_set.emit(false)
	board_2d_node.clear_pieces_from_board()
	board_2d_node.board = board
	board_2d_node.initalize_board_peices()
	board_2d_node.can_select_any_thing = true


## Signal emitted upon turn_is_white changing
signal turn_changed(new_turn: bool)

## Variable tracking who's turn it is in the current chess game.
var turn_is_white: bool = true:
	set(value):
		turn_is_white = value
		turn_changed.emit(turn_is_white)

## The matrix of pieces is stored in the Board object.
## This variable is always the latest and active board.
var board: Board = Board.new()

## Stores every instance of Board after every completed move
var board_history: Array[Board] = []

## Stores every completed move
var move_history: Array[Move] = []


func _ready() -> void:
	
	connect_to_network_handler_signals()
	connect_to_history_signals()
	
	set_normal_starting_board()
	
	if not NetworkHandler.multiplayer.is_server():
		
		create_board_2d()


## Contains this chess_games instance of Board2D
var board_2d_node: Board2D

## Packed scene containing the board_2d
var board_2d_scene: PackedScene = preload("res://display_board/board_2d/board_2d.tscn")

## Instantiates a new board_2d, connects signals, and tells it to display the board.
func create_board_2d() -> void:
	var board_2d: Board2D = board_2d_scene.instantiate()
	
	board_2d_node = board_2d
	
	# connecting signals
	board_2d.on_input_move.connect(on_input_move)
	turn_changed.connect(board_2d.on_chess_game_turn_changed)
	
	# initalizing visuals
	board_2d.board = board
	board_2d.setup_board_pieces()
	
	# the rotation buttons need a reference to the chess game
	var history_node: Node = board_2d.get_node("CanvasLayer/GameGUI").get_node("Panel/BoardControls/History")
	history_node.chess_game = self
	
	# initalizing team
	if NetworkHandler.is_in_match:
		
		board_2d.rotate_board(NetworkHandler.team_is_white)
	
	add_child(board_2d)

## Connected to a board_2d or board_3d which handle getting input.
## Either sends the move to the server if playing multiplayer or completes the move.
func on_input_move(move: Move) -> void:
	
	# if playing multiplayer send the move to the server
	if NetworkHandler.is_in_match:
		NetworkHandler.send_server_move(move)
		
	else:
		
		complete_move(move)

## Saves the move, changes the board, checks for a win, and changes the turn.
func complete_move(move: Move) -> void:
	save_board_and_move(move)
		
	board.complete_move(move)
	
	var opponent_team_is_white: bool = not turn_is_white
	
	if not NetworkHandler.is_in_match and not NetworkHandler.multiplayer.is_server() and board.check_for_loss(opponent_team_is_white):
		if opponent_team_is_white:
			Globals.on_game_end.emit(Globals.RESULT.BLACK_WIN)
		else:
			Globals.on_game_end.emit(Globals.RESULT.WHITE_WIN)
		
	
	turn_is_white = not turn_is_white


## Stores the current board in board_history and the completed_move to move_history
func save_board_and_move(move: Move) -> void:
	board_history.append(board.duplicate())
	move_history.append(move)

## Server function.
## Gets if the move is valid from the current board and returns the result.
func is_move_valid(move: Move, team_is_white: bool) -> bool:
	return board.is_move_valid(move, team_is_white)

func check_for_match_end(team_is_white : bool):
	if board.check_for_loss(team_is_white):
		if team_is_white:
			return Globals.RESULT.BLACK_WIN
		else:
			return Globals.RESULT.WHITE_WIN
	return null

## Called by ready.
## Connects to signal emitted upon receiving a move from the server.
func connect_to_network_handler_signals() -> void:
	NetworkHandler.on_client_complete_move.connect(on_client_complete_move)

## Updates the clients board with the move.
func on_client_complete_move(move: Move) -> void:
	complete_move(move)

## Used only by pawn move sets to determine if enpassant is possible
func get_last_move() -> Move:
	return move_history[-1]

## Initalizes the member board variable with a normal chess starting board.
func set_normal_starting_board() -> void:
	
	# black pawns
	var y_position_black_pawns: int = 1
	var normal_black_pawn: Piece = Piece.new(Globals.TYPE.PAWN, false, [MoveSet.new(Globals.TYPE.PAWN, self, false)])
	for x: int in range(board.board_length):
		
		var position: Vector2i = Vector2i(x,y_position_black_pawns)
		board.set_contents_at_position_to(position, normal_black_pawn.duplicate())
	
	# white pawns
	var y_position_white_pawns: int = board.board_length - 2
	var normal_white_pawn: Piece = Piece.new(Globals.TYPE.PAWN, true, [MoveSet.new(Globals.TYPE.PAWN, self, true)])
	for x: int in range(board.board_length):
		
		var position: Vector2i = Vector2i(x,y_position_white_pawns)
		board.set_contents_at_position_to(position, normal_white_pawn.duplicate())
	
	# all the other pieces
	# black rooks
	board.set_contents_at_position_to(Vector2i(0,0), Piece.new(Globals.TYPE.ROOK, false, [MoveSet.new(Globals.TYPE.ROOK, self, false)]))
	board.set_contents_at_position_to(Vector2i(7,0), Piece.new(Globals.TYPE.ROOK, false, [MoveSet.new(Globals.TYPE.ROOK, self, false)]))
	# white rooks
	board.set_contents_at_position_to(Vector2i(0,7), Piece.new(Globals.TYPE.ROOK, true, [MoveSet.new(Globals.TYPE.ROOK, self, true)]))
	board.set_contents_at_position_to(Vector2i(7,7), Piece.new(Globals.TYPE.ROOK, true, [MoveSet.new(Globals.TYPE.ROOK, self, true)]))
	# black knights
	board.set_contents_at_position_to(Vector2i(1,0), Piece.new(Globals.TYPE.KNIGHT, false, [MoveSet.new(Globals.TYPE.KNIGHT, self, false)]))
	board.set_contents_at_position_to(Vector2i(6,0), Piece.new(Globals.TYPE.KNIGHT, false, [MoveSet.new(Globals.TYPE.KNIGHT, self, false)]))
	# white knights
	board.set_contents_at_position_to(Vector2i(1,7), Piece.new(Globals.TYPE.KNIGHT, true, [MoveSet.new(Globals.TYPE.KNIGHT, self, true)]))
	board.set_contents_at_position_to(Vector2i(6,7), Piece.new(Globals.TYPE.KNIGHT, true, [MoveSet.new(Globals.TYPE.KNIGHT, self, true)]))
	# black bishops
	board.set_contents_at_position_to(Vector2i(2,0), Piece.new(Globals.TYPE.BISHOP, false, [MoveSet.new(Globals.TYPE.BISHOP, self, false)]))
	board.set_contents_at_position_to(Vector2i(5,0), Piece.new(Globals.TYPE.BISHOP, false, [MoveSet.new(Globals.TYPE.BISHOP, self, false)]))
	# white bishops
	board.set_contents_at_position_to(Vector2i(2,7), Piece.new(Globals.TYPE.BISHOP, true, [MoveSet.new(Globals.TYPE.BISHOP, self, true)]))
	board.set_contents_at_position_to(Vector2i(5,7), Piece.new(Globals.TYPE.BISHOP, true, [MoveSet.new(Globals.TYPE.BISHOP, self, true)]))
	# black royalty
	board.set_contents_at_position_to(Vector2i(3,0), Piece.new(Globals.TYPE.QUEEN, false, [MoveSet.new(Globals.TYPE.QUEEN, self, false)]))
	board.set_contents_at_position_to(Vector2i(4,0), Piece.new(Globals.TYPE.KING, false, [MoveSet.new(Globals.TYPE.KING, self, false)]))
	# white royalty
	board.set_contents_at_position_to(Vector2i(3,7), Piece.new(Globals.TYPE.QUEEN, true, [MoveSet.new(Globals.TYPE.QUEEN, self, true)]))
	board.set_contents_at_position_to(Vector2i(4,7), Piece.new(Globals.TYPE.KING, true, [MoveSet.new(Globals.TYPE.KING, self, true)]))
