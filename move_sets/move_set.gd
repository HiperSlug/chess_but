extends RefCounted
class_name MoveSet


var team_is_white: bool
func _get_all_available_moves(_current_board_matrix: Array[Array], _piece_position: Vector2i, _piece_team_is_white: bool, _total_move_count: int = 0, _do_king_check = true) -> Array[Move]: # virtual
	return [Move.new(Vector2i.ZERO,Vector2i.ZERO,Vector2i(-1,-1))]

func _init(_team_is_white: bool = true) -> void:
	self.team_is_white = _team_is_white



func is_in_bounds(position: Vector2i) -> bool: # May run into some problems if I end up changing the board size later.
	var x_in_bounds: bool = position.x < Globals.board_length and position.x >= 0
	var y_in_bounds: bool = position.y < Globals.board_length and position.y >= 0
	var in_bounds: bool = x_in_bounds and y_in_bounds
	return in_bounds
