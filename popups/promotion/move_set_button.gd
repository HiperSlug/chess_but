extends Button

@export var type: Globals.TYPE

signal move_set_chosen(type: Globals.TYPE)
func _pressed() -> void:
	move_set_chosen.emit(type)

func _ready() -> void:
	$MoveSetIcon.set_type(type)


func set_team(team_is_white) -> void:
	$MoveSetIcon.set_team(team_is_white)
