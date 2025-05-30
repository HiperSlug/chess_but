extends Node
class_name ChessGame


signal new_turn(turn_is_white: bool)
var turn_is_white: bool = true
var board: Board = Board.new(8)

func _ready() -> void:
	NetworkHandler.on_networking_received_valid_input.connect(on_network_handler_received_valid_input)
	NetworkHandler.network_request_promotion_type.connect(on_network_request_promotion_type)
	NetworkHandler.on_receive_promotion.connect(on_network_receive_promotion_order)
	
	set_normal_starting_board(board)
	
	if not NetworkHandler.multiplayer.is_server():
		create_board_2d()
		

var board_2d_scene: PackedScene = preload("res://board/board_2d/board_2d.tscn")
func create_board_2d() -> void:
	var board_2d: Board2D = board_2d_scene.instantiate()
	board_2d.input_move.connect(on_input_move)
	new_turn.connect(board_2d.set_turn)
	board_2d.initalize_board(board)
	if NetworkHandler.is_in_match:
		board_2d.team_is_white = NetworkHandler.team_is_white
		board_2d.rotate_board(NetworkHandler.team_is_white)
	
	add_child(board_2d)

var board_history: Array[Board] = []
var move_history: Array[Move] = []

func on_input_move(move: Move) -> void:
	if NetworkHandler.is_in_match:
		var move_dict: Dictionary = move.serialize()
		NetworkHandler.input.rpc_id(1, NetworkHandler.multiplayer.get_unique_id(), NetworkHandler.current_match_id, move_dict)
	else:
		save_board(move)
		board.complete_move(move)
		turn_is_white = not turn_is_white
		new_turn.emit(turn_is_white) # connect to board2d

func is_move_valid(move: Move, team_is_white: bool, match_id: int) -> bool:
	var is_valid: bool = board.is_move_valid(move, team_is_white)
	if is_valid:
		save_board(move)
		board.complete_move(move, match_id)
		turn_is_white = not turn_is_white
		new_turn.emit(turn_is_white)
		
		if board.check_for_loss(not team_is_white):
			NetworkHandler.end_match(match_id, not team_is_white)
	
	return is_valid

func on_network_handler_received_valid_input(move: Move) -> void:
	save_board(move)
	board.complete_move(move)
	turn_is_white = not turn_is_white
	new_turn.emit(turn_is_white)

func on_network_request_promotion_type(position: Vector2i) -> void:
	var contents = board.get_contents_at_position(position)
	
	if contents == null:
		# request board sync with server
		pass
	
	contents = contents as Piece
	contents.get_promotion_type.emit(position)

func on_network_receive_promotion_order(type: Globals.TYPE, position: Vector2i) -> void:
	var contents = board.get_contents_at_position(position)
	
	if contents == null:
		# request board sync with server
		pass
	
	contents = contents as Piece
	contents.promote(type)

func save_board(move: Move) -> void:
	board_history.append(board.duplicate())
	move_history.append(move)

func check_for_win(team_is_white: bool) -> bool:
	var win: bool = board.check_for_loss(not team_is_white)
	return win

func get_last_move() -> Move:
	return move_history[-1]

func set_normal_starting_board(_board: Board) -> void:
	
	# black pawns
	var y_position_black_pawns: int = 1
	var normal_black_pawn: Piece = Piece.new(Globals.TYPE.PAWN, false, [MoveSet.new(Globals.TYPE.PAWN, self, false)])
	for x: int in range(board.board_length):
		
		var position: Vector2i = Vector2i(x,y_position_black_pawns)
		_board.set_contents_at_position_to(position, normal_black_pawn.duplicate())
	
	# white pawns
	var y_position_white_pawns: int = _board.board_length - 2
	var normal_white_pawn: Piece = Piece.new(Globals.TYPE.PAWN, true, [MoveSet.new(Globals.TYPE.PAWN, self, true)])
	for x: int in range(board.board_length):
		
		var position: Vector2i = Vector2i(x,y_position_white_pawns)
		_board.set_contents_at_position_to(position, normal_white_pawn.duplicate())
	
	# all the other pieces
	# black rooks
	_board.set_contents_at_position_to(Vector2i(0,0), Piece.new(Globals.TYPE.ROOK, false, [MoveSet.new(Globals.TYPE.ROOK, self, false)]))
	_board.set_contents_at_position_to(Vector2i(7,0), Piece.new(Globals.TYPE.ROOK, false, [MoveSet.new(Globals.TYPE.ROOK, self, false)]))
	# white rooks
	_board.set_contents_at_position_to(Vector2i(0,7), Piece.new(Globals.TYPE.ROOK, true, [MoveSet.new(Globals.TYPE.ROOK, self, true)]))
	_board.set_contents_at_position_to(Vector2i(7,7), Piece.new(Globals.TYPE.ROOK, true, [MoveSet.new(Globals.TYPE.ROOK, self, true)]))
	# black knights
	_board.set_contents_at_position_to(Vector2i(1,0), Piece.new(Globals.TYPE.KNIGHT, false, [MoveSet.new(Globals.TYPE.KNIGHT, self, false)]))
	_board.set_contents_at_position_to(Vector2i(6,0), Piece.new(Globals.TYPE.KNIGHT, false, [MoveSet.new(Globals.TYPE.KNIGHT, self, false)]))
	# white knights
	_board.set_contents_at_position_to(Vector2i(1,7), Piece.new(Globals.TYPE.KNIGHT, true, [MoveSet.new(Globals.TYPE.KNIGHT, self, true)]))
	_board.set_contents_at_position_to(Vector2i(6,7), Piece.new(Globals.TYPE.KNIGHT, true, [MoveSet.new(Globals.TYPE.KNIGHT, self, true)]))
	# black bishops
	_board.set_contents_at_position_to(Vector2i(2,0), Piece.new(Globals.TYPE.BISHOP, false, [MoveSet.new(Globals.TYPE.BISHOP, self, false)]))
	_board.set_contents_at_position_to(Vector2i(5,0), Piece.new(Globals.TYPE.BISHOP, false, [MoveSet.new(Globals.TYPE.BISHOP, self, false)]))
	# white bishops
	_board.set_contents_at_position_to(Vector2i(2,7), Piece.new(Globals.TYPE.BISHOP, true, [MoveSet.new(Globals.TYPE.BISHOP, self, true)]))
	_board.set_contents_at_position_to(Vector2i(5,7), Piece.new(Globals.TYPE.BISHOP, true, [MoveSet.new(Globals.TYPE.BISHOP, self, true)]))
	# black royalty
	_board.set_contents_at_position_to(Vector2i(3,0), Piece.new(Globals.TYPE.QUEEN, false, [MoveSet.new(Globals.TYPE.QUEEN, self, false)]))
	_board.set_contents_at_position_to(Vector2i(4,0), Piece.new(Globals.TYPE.KING, false, [MoveSet.new(Globals.TYPE.KING, self, false)]))
	# white royalty
	_board.set_contents_at_position_to(Vector2i(3,7), Piece.new(Globals.TYPE.QUEEN, true, [MoveSet.new(Globals.TYPE.QUEEN, self, true)]))
	_board.set_contents_at_position_to(Vector2i(4,7), Piece.new(Globals.TYPE.KING, true, [MoveSet.new(Globals.TYPE.KING, self, true)]))
