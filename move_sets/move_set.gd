extends RefCounted
class_name MoveSet


var team_is_white: bool

func _get_all_available_moves(_board: Board, _piece_position: Vector2i) -> Array[Move]:
	return [Move.new(Vector2i.ZERO,Vector2i.ZERO,Vector2i(-1,-1))]

func _init(_team_is_white: bool) -> void:
	self.team_is_white = _team_is_white



func is_in_bounds(position: Vector2i) -> bool:
	var x_in_bounds: bool = position.x < 8 and position.x >= 0
	var y_in_bounds: bool = position.y < 8 and position.y >= 0
	var in_bounds: bool = x_in_bounds and y_in_bounds
	return in_bounds
