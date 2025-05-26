extends RefCounted
class_name Board

const length: int = 8

func _init() -> void:
	current_board_matrix.resize(length)
	for y_array: Array in current_board_matrix:
		y_array.resize(length)
		
	# Do this is ChessGame
	current_board_matrix[0][1] = Piece.new(Piece.TYPE.KNIGHT, false, KnightMoveSet.new(false))
	current_board_matrix[1][5] = Piece.new(Piece.TYPE.PAWN, true, PawnMoveSet.new(true))
	current_board_matrix[2][0] = Piece.new(Piece.TYPE.PAWN, true, PawnMoveSet.new(true))

var current_board_matrix: Array[Array]
var board_history: Array[Array] # Used to allow undoing moves
var move_history: Array[Move]

func do_move(move: Move) -> Move:
	
	# history
	board_history.append(current_board_matrix.duplicate(true))
	move_history.append(move)
	
	var piece: Piece = current_board_matrix[move.inital_position.x][move.inital_position.y]
	move.set_moved_piece_id(piece.piece_id)
	
	# kill
	if move.kill_position != Vector2i(-1, -1):
		
		var killed_piece: Piece = current_board_matrix[move.kill_position.x][move.kill_position.y]
		move.set_killed_piece_id(killed_piece.piece_id)
		piece.kill(killed_piece)
		
		current_board_matrix[move.kill_position.x][move.kill_position.y] = null
	
	else:
		move.set_killed_piece_id(-1)
	
	# move
	current_board_matrix[move.final_position.x][move.final_position.y] = piece
	current_board_matrix[move.inital_position.x][move.inital_position.y] = null
	
	if move.do_promotion:
		var team_is_white: bool = piece.remove_move_set(move.promotion_move_set)
		piece.add_move_set(KingMoveSet.new(team_is_white))
		print("PROMOTE")
	
	piece.total_move_count += 1
	
	return move # yes I know I dont have to return anything


func get_contents_at(position: Vector2i):
	return current_board_matrix[position.x][position.y]

func get_last_move() -> Move:
	return move_history[-1]
