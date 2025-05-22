extends RefCounted
class_name Move

var inital_position: Vector2i
var new_position: Vector2i
var kill_position: Vector2i # (-1, -1) means nothing is being killed

func _init(_inital_position: Vector2i, _new_position: Vector2i, _kill_position: Vector2i) -> void:
	self.inital_position = _inital_position
	self.new_position = _new_position
	self.kill_position = _kill_position
