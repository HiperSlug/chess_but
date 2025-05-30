extends HBoxContainer

func _ready() -> void:
	Globals.on_hisotry_mode_set.connect(on_chess_game_history_mode_set)
	Globals.on_hisotry_position_set.connect(on_chess_game_history_position_set)
	Globals.on_first_move.connect(on_first_move)
	
	on_chess_game_history_mode_set(false)
	on_chess_game_history_position_set(0)

func on_first_move() -> void:
	on_chess_game_history_position_set(1)

func on_chess_game_history_mode_set(history_mode_active: bool) -> void:
	if history_mode_active:
		$Next.modulate = Color.WHITE
		$Next/Button.disabled = false
		$Current.modulate = Color.WHITE
		$Current/Button.disabled = false
	else:
		$Next.modulate = Color.GRAY
		$Next/Button.disabled = true
		$Current.modulate = Color.GRAY
		$Current/Button.disabled = true

# and I will succedde with the power of JANK

func on_chess_game_history_position_set(history_position: int) -> void:
	if history_position == 0:
		$First.modulate = Color.GRAY
		$First/Button.disabled = true
		$Back.modulate = Color.GRAY
		$Back/Button.disabled = true
	else:
		$First.modulate = Color.WHITE
		$First/Button.disabled = false
		$Back.modulate = Color.WHITE
		$Back/Button.disabled = false

func _on_first_button_pressed() -> void:
	Globals.on_history_first_pressed.emit()


func _on_back_button_pressed() -> void:
	Globals.on_history_back_pressed.emit()


func _on_next_button_pressed() -> void:
	Globals.on_history_forward_pressed.emit()


func _on_current_button_pressed() -> void:
	Globals.on_history_current_pressed.emit()
