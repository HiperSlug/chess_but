@tool
extends TextureRect
class_name MoveSetIcon


var move_set: MoveSet
@export var override_visuals: bool
@export var visual: Globals.TYPE
@export var team_is_white: bool

func _ready() -> void:
	update_texture()

func update_texture() -> void:
	
	if override_visuals:
		texture = Globals.texture_dictionary[visual][team_is_white]
	else:
		texture = Globals.texture_dictionary[move_set.type][move_set.team_is_white]
