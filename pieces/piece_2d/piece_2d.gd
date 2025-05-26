extends Node2D
class_name Piece2D


@export var type: Globals.TYPE = Globals.TYPE.PAWN
@export var team_is_white: bool = true

var display_icon_scene: PackedScene = preload("res://move_sets/icon/move_set_icon.tscn")
var displayed_move_sets: Array[MoveSet]

func _ready() -> void:
	$Sprite2D.texture = Globals.texture_dictionary[type][team_is_white]
	
	for move_set: MoveSet in displayed_move_sets:
		var display_icon = display_icon_scene.instantiate()
		
		display_icon.type = move_set.type
		
		$Sprite2D/HBoxContainer.add_child(display_icon)
