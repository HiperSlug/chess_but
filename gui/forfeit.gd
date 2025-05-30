extends TextureRect

func _ready() -> void:
	if NetworkHandler.is_in_match:
		show()
	else:
		hide()

func _on_button_pressed() -> void:
	NetworkHandler.forfeit.rpc_id(1, NetworkHandler.current_match_id, NetworkHandler.multiplayer.get_unique_id())
