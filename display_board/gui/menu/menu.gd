extends Button


func _pressed() -> void:
	
	if NetworkHandler.client_match_id != 0:
	
		if NetworkHandler.is_in_match:
			NetworkHandler.forfeit()
		NetworkHandler.leave_match()
	
	get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
