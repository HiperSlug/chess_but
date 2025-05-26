extends RefCounted
class_name Move

var inital_position: Vector2i
var final_position: Vector2i
var kill_position: Vector2i # (-1, -1) means nothing is being killed

var moved_piece_id: int
var killed_piece_id: int

var do_promotion: bool
var promotion_move_set: MoveSet

func _init(_inital_position: Vector2i, _final_position: Vector2i, _kill_position: Vector2i, _do_promotion: bool = false) -> void:
	self.inital_position = _inital_position
	self.final_position = _final_position
	self.kill_position = _kill_position
	self.do_promotion = _do_promotion

func set_moved_piece_id(_moved_piece_id: int) -> void:
	self.moved_piece_id = _moved_piece_id
	

func set_killed_piece_id(_killed_piece_id: int) -> void:
	self.killed_piece_id = _killed_piece_id
