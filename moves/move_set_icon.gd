extends Panel
class_name MoveSetIcon

var move_set: MoveSet

@export var type: Globals.TYPE
@export var team_is_white: bool

func _ready() -> void:
	if move_set != null:
		type = move_set.type
		team_is_white = move_set.team_is_white
	update_texture()

func update_texture() -> void:
	$Panel.texture = Globals.texture_dictionary[type][team_is_white]

func set_team(_team_is_white: bool) -> void:
	team_is_white = _team_is_white
	update_texture()

func set_type(_type: Globals.TYPE) -> void:
	type = _type
	update_texture()
