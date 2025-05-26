extends Node





var board: Board = Board.new()
func _ready() -> void:
	$Board2D.initalize_board(board)
	$Board2D.move_completed.connect(do_move)

func do_move(move: Move) -> void:
	var updated_move: Move = board.do_move(move)
	$Board2D.update_pieces(move)


func does_piece_exist(piece_position: Vector2i) -> bool:
	var piece = board.current_board_matrix[piece_position.x][piece_position.y]
	if piece == null:
		return false
	return true

func get_all_moves_at_position(piece_position: Vector2i) -> Array[Move]: # Called by board object
	
	var piece = board.current_board_matrix[piece_position.x][piece_position.y]
	
	var moves: Array[Move] = piece.get_all_available_moves(board, piece_position)
	
	return moves
