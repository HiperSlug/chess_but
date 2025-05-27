extends Control

signal move_set_chosen(move_set: Globals.TYPE)

func _ready() -> void:
	# connect signals
	for button: Button in $HBoxContainer.get_children():
		button.move_set_chosen.connect(on_move_set_chosen)
	
	Globals.set_mouse_pickable_enabled.emit(false)

func on_move_set_chosen(move_set_type: Globals.TYPE) -> void:
	move_set_chosen.emit(move_set_type)
	Globals.set_mouse_pickable_enabled.emit(true)

func set_team(team_is_white) -> void:
	for button: Button in $HBoxContainer.get_children():
		button.set_team(team_is_white)
