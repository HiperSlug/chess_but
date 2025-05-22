extends Node
class_name Board

var length: int = 8

func _init() -> void:
	current_board_matrix.resize(length)
	for y_array: Array in current_board_matrix:
		y_array.resize(length)

var current_board_matrix: Array[Array]
var board_history: Array[Array]
var move_history: Array[Move]

func do_move(move: Move) -> void:
	
	# history
	board_history.append(current_board_matrix.duplicate(true))
	move_history.append(move)
	
	# kill
	if move.kill_position != Vector2i(-1,-1):
		current_board_matrix[move.kill_position.x][move.kill_position.y].queue_free()
		current_board_matrix[move.kill_position.x][move.kill_position.y] = null
	# move
	var piece: Piece = current_board_matrix[move.inital_position.x][move.inital_position.y]
	current_board_matrix[move.new_position.x][move.new_position.y] = piece
	current_board_matrix[move.inital_position.x][move.inital_position.y] = null
	
	piece.total_move_count += 1
	

func get_last_move() -> Move:
	return move_history[-1]
