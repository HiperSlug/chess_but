extends Button

var team_is_white: bool
@export var move_set_type: Globals.TYPE

var type_to_move_set: Dictionary = {
	Globals.TYPE.ROOK : {
		true : RookMoveSet.new(true),
		false : RookMoveSet.new(false),
	},
	Globals.TYPE.QUEEN : {
		true : QueenMoveSet.new(true),
		false : QueenMoveSet.new(false),
	},
	Globals.TYPE.KNIGHT : {
		true : KnightMoveSet.new(true),
		false : KnightMoveSet.new(false),
	},
	Globals.TYPE.BISHOP : {
		true : BishopMoveSet.new(true),
		false : BishopMoveSet.new(false),
	},
}

signal chosen_move_set(move_set: MoveSet)

func _pressed() -> void:
	chosen_move_set.emit(type_to_move_set[move_set_type][team_is_white])
