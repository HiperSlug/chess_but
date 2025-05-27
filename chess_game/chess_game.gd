extends Node
class_name ChessGame



var board: Board = Board.new(Globals.board_length)
func _ready() -> void:
	Globals.board = board
	Globals.chess_game = self
	board.move_completed.connect(save_board)
	
	set_normal_starting_board(board)
	$Board2D.initalize_board(board)

var board_history: Array[Board] = []
var move_history: Array[Move] = []

func save_board(move: Move) -> void:
	board_history.append(board.duplicate())
	move_history.append(move)

func get_last_move() -> Move:
	return move_history[-1]

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
