extends TextureRect

func _ready() -> void:
	NetworkHandler.set_is_in_match.connect(on_is_in_match_update)
	on_is_in_match_update(NetworkHandler.is_in_match)

func on_is_in_match_update(is_in_match: bool) -> void:
	if is_in_match:
		modulate = Color.GRAY
	else:
		modulate = Color.WHITE

func _on_button_pressed() -> void:
	if not NetworkHandler.is_in_match:
		
		NetworkHandler.client_tell_server_leave_match.rpc_id(1, NetworkHandler.current_match_id, NetworkHandler.multiplayer.get_unique_id())
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
