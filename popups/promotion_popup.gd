extends Control

signal move_set_chosen(move_set: MoveSet)
var team_is_white: bool = true

func _ready() -> void:
	for button: Button in $HBoxContainer.get_children():
		button.team_is_white = team_is_white
		button.chosen_move_set.connect(on_move_set_chosen)
		button.get_child(0).team_is_white = team_is_white

func on_move_set_chosen(move_set: MoveSet) -> void:
	move_set_chosen.emit(move_set)
