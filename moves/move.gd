extends RefCounted
class_name Move

var inital_position: Vector2i
var final_position: Vector2i
var kill_position: Vector2i # (-1, -1) means nothing is being killed
var do_promotion: bool
var promotion_type: Globals.TYPE
var secondary_move: Move


func _init(_inital_position: Vector2i = Vector2i.ZERO, _final_position: Vector2i = Vector2i.ZERO, _kill_position: Vector2i = Vector2i(-1,-1),\
 _do_promotion: bool = false, _promotion_type: Globals.TYPE = Globals.TYPE.PAWN, _secondary_move = null) -> void:
	self.inital_position = _inital_position
	self.final_position = _final_position
	self.kill_position = _kill_position
	self.secondary_move = _secondary_move
	self.do_promotion = _do_promotion
	self.promotion_type = _promotion_type

func equals_except_promotion(move: Move) -> bool:
	var same_inital_position: bool = inital_position == move.inital_position
	var same_final_position: bool = final_position == move.final_position
	var same_kill_position: bool = kill_position == move.kill_position
	var same_do_promotion: bool = do_promotion == move.do_promotion
	
	var same_secondary_move: bool
	if secondary_move:
		if move.secondary_move:
			same_secondary_move = secondary_move.equals(move.secondary_move)
		else:
			same_secondary_move = false
	else:
		if move.secondary_move:
			same_secondary_move = false
		else:
			same_secondary_move = true
	
	
	return same_final_position and same_inital_position and same_kill_position and same_secondary_move\
	 and same_do_promotion

func serialize() -> Dictionary:
	var dictionary: Dictionary = {
		"inital_position" : inital_position,
		"final_position" : final_position,
		"kill_position" : kill_position,
		"do_promotion" : do_promotion,
		"promotion_type" : promotion_type,
	}
	
	if secondary_move == null:
		dictionary["secondary_move"] = null
	else:
		dictionary["secondary_move"] = secondary_move.serialize()
	
	return dictionary

static func deserialize(dictionary: Dictionary) -> Move:
	return Move.new(dictionary["inital_position"], dictionary["final_position"], dictionary["kill_position"],\
	 dictionary["do_promotion"], dictionary["promotion_type"], dictionary["secondary_move"])
