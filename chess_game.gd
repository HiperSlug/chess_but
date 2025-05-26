extends Node




var board: Board = Board.new()
func _ready() -> void:
	Globals.board = board
	board.set_contents_at(Vector2i(3,3), Piece.new(Globals.TYPE.KING,true,KingMoveSet.new(true)))
	board.set_contents_at(Vector2i(5,5), Piece.new(Globals.TYPE.KNIGHT,false,KnightMoveSet.new(false)))
	board.set_contents_at(Vector2i(5,6), Piece.new(Globals.TYPE.QUEEN,false,QueenMoveSet.new(true)))
	board.set_contents_at(Vector2i(0,3),Piece.new(Globals.TYPE.ROOK,true, RookMoveSet.new(true)))
	board.set_contents_at(Vector2i(7,3),Piece.new(Globals.TYPE.ROOK,true, RookMoveSet.new(true)))
	board.set_contents_at(Vector2i(2,1),Piece.new(Globals.TYPE.PAWN,false,PawnMoveSet.new(false)))
	board.set_contents_at(Vector2i(3,6),Piece.new(Globals.TYPE.PAWN,true,PawnMoveSet.new(true)))
	$Board2D.initalize_board(board)
