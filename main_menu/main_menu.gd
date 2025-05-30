extends Control


func _on_be_server_pressed() -> void:
	NetworkHandler.create_server(NetworkHandler.PORT)


func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_file("res://chess_game/chess_game.tscn")


func _on_online_pressed() -> void:
	NetworkHandler.queue_for_game.rpc_id(1, multiplayer.get_unique_id())


func _on_connect_to_server_pressed() -> void:
	NetworkHandler.create_client(NetworkHandler.URL)


func _on_line_edit_text_changed(new_text: String) -> void:
	NetworkHandler.display_name = new_text
