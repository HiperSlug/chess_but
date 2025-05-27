extends Node
class_name ChessGame


var playing_multiplayer: bool = false

var turn_is_white: bool = true
var board: Board = Board.new(Globals.board_length)
func _ready() -> void:
	Globals.board = board
	Globals.chess_game = self
	
	
	set_normal_starting_board(board)
	$Board2D.initalize_board(board)

var board_history: Array[Board] = []
var move_history: Array[Move] = []

func on_input_move(move: Move) -> void:
	if playing_multiplayer:
		request_move(move)
	else:
		save_board(move)
		board.complete_move(move)
		var win: bool = board.check_for_loss(not turn_is_white)
		if win:
			print("GAME FINISHED")
		turn_is_white = not turn_is_white
		$Board2D.turn_is_white = turn_is_white

func save_board(move: Move) -> void:
	board_history.append(board.duplicate())
	move_history.append(move)

func get_last_move() -> Move:
	return move_history[-1]

func request_move(move: Move) -> void:
	var move_dict: Dictionary = move.serialize()
	validate_move.rpc(move_dict)

@rpc("any_peer","reliable","call_local")
func validate_move(move_dict: Dictionary) -> void:
	if multiplayer.is_server():
		print("validation of no cheat")
		client_apply_move.rpc(move_dict)

@rpc("authority","reliable","call_local")
func client_apply_move(move_dict: Dictionary) -> void:
	var move: Move = Move.deserialize(move_dict)
	save_board(move)
	board.complete_move(move)
	#var win: bool = board.check_for_loss(not turn_is_white)
	#if win:
		#print("GAME FINISHED")
	turn_is_white = not turn_is_white
	$Board2D.turn_is_white = turn_is_white

const PORT: int = 4040
const ADDRESS: String = "127.0.0.1"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("host"):
		host_game()
	elif event.is_action_pressed("client"):
		join_game(ADDRESS)
	elif event.is_action_pressed("disconnect"):
		disconnect_from_server()

func host_game() -> void:
	print("hosting")
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(PORT,2)
	multiplayer.multiplayer_peer = peer
	playing_multiplayer = true

func join_game(ip: String) -> void:
	print("joining")
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = peer
	playing_multiplayer = true

func disconnect_from_server() -> void:
	multiplayer.multiplayer_peer = null
	playing_multiplayer = false

func set_normal_starting_board(_board: Board) -> void:
	
	# black pawns
	var y_position_black_pawns: int = 1
	var normal_black_pawn: Piece = Piece.new(Globals.TYPE.PAWN, false, [MoveSet.new(Globals.TYPE.PAWN, false)])
	for x: int in range(board.board_length):
		
		var position: Vector2i = Vector2i(x,y_position_black_pawns)
		_board.set_contents_at_position_to(position, normal_black_pawn.duplicate())
	
	# white pawns
	var y_position_white_pawns: int = _board.board_length - 2
	var normal_white_pawn: Piece = Piece.new(Globals.TYPE.PAWN, true, [MoveSet.new(Globals.TYPE.PAWN, true)])
	for x: int in range(board.board_length):
		
		var position: Vector2i = Vector2i(x,y_position_white_pawns)
		_board.set_contents_at_position_to(position, normal_white_pawn.duplicate())
	
	# all the other pieces
	# black rooks
	_board.set_contents_at_position_to(Vector2i(0,0), Piece.new(Globals.TYPE.ROOK, false, [MoveSet.new(Globals.TYPE.ROOK, false)]))
	_board.set_contents_at_position_to(Vector2i(7,0), Piece.new(Globals.TYPE.ROOK, false, [MoveSet.new(Globals.TYPE.ROOK, false)]))
	# white rooks
	_board.set_contents_at_position_to(Vector2i(0,7), Piece.new(Globals.TYPE.ROOK, true, [MoveSet.new(Globals.TYPE.ROOK, true)]))
	_board.set_contents_at_position_to(Vector2i(7,7), Piece.new(Globals.TYPE.ROOK, true, [MoveSet.new(Globals.TYPE.ROOK, true)]))
	# black knights
	_board.set_contents_at_position_to(Vector2i(1,0), Piece.new(Globals.TYPE.KNIGHT, false, [MoveSet.new(Globals.TYPE.KNIGHT, false)]))
	_board.set_contents_at_position_to(Vector2i(6,0), Piece.new(Globals.TYPE.KNIGHT, false, [MoveSet.new(Globals.TYPE.KNIGHT, false)]))
	# white knights
	_board.set_contents_at_position_to(Vector2i(1,7), Piece.new(Globals.TYPE.KNIGHT, true, [MoveSet.new(Globals.TYPE.KNIGHT, true)]))
	_board.set_contents_at_position_to(Vector2i(6,7), Piece.new(Globals.TYPE.KNIGHT, true, [MoveSet.new(Globals.TYPE.KNIGHT, true)]))
	# black bishops
	_board.set_contents_at_position_to(Vector2i(2,0), Piece.new(Globals.TYPE.BISHOP, false, [MoveSet.new(Globals.TYPE.BISHOP, false)]))
	_board.set_contents_at_position_to(Vector2i(5,0), Piece.new(Globals.TYPE.BISHOP, false, [MoveSet.new(Globals.TYPE.BISHOP, false)]))
	# white bishops
	_board.set_contents_at_position_to(Vector2i(2,7), Piece.new(Globals.TYPE.BISHOP, true, [MoveSet.new(Globals.TYPE.BISHOP, true)]))
	_board.set_contents_at_position_to(Vector2i(5,7), Piece.new(Globals.TYPE.BISHOP, true, [MoveSet.new(Globals.TYPE.BISHOP, true)]))
	# black royalty
	_board.set_contents_at_position_to(Vector2i(3,0), Piece.new(Globals.TYPE.QUEEN, false, [MoveSet.new(Globals.TYPE.QUEEN, false)]))
	_board.set_contents_at_position_to(Vector2i(4,0), Piece.new(Globals.TYPE.KING, false, [MoveSet.new(Globals.TYPE.KING, false)]))
	# white royalty
	_board.set_contents_at_position_to(Vector2i(3,7), Piece.new(Globals.TYPE.QUEEN, true, [MoveSet.new(Globals.TYPE.QUEEN, true)]))
	_board.set_contents_at_position_to(Vector2i(4,7), Piece.new(Globals.TYPE.KING, true, [MoveSet.new(Globals.TYPE.KING, true)]))
