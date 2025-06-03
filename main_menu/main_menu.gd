extends Control


func _on_single_player_pressed() -> void:
	get_tree().change_scene_to_file("res://chess_game/chess_game.tscn")


var queued: bool = false
func _on_online_pressed() -> void:
	if queued:
		$CanvasLayer/Play/VBoxContainer/QueueOnline.text = "Queue Online"
		NetworkHandler.dequeue_for_game()
		queued = false
	else:
		$CanvasLayer/Play/VBoxContainer/QueueOnline.text = "Dequeue Online"
		NetworkHandler.queue_for_game()
		queued = true
	

var display_name_set_by_player: bool = false
func _ready() -> void:
	$CanvasLayer/Play/VBoxContainer/QueueOnline.disabled = true
	$CanvasLayer/Play/VBoxContainer/QueueOnline.text = "Queue Online"
	
	if NetworkHandler.is_client_connected_to_server:
		$CanvasLayer/Play/VBoxContainer/QueueOnline.disabled = false
	
	set_default_display_name()
	set_connection_status(NetworkHandler.is_client_connected_to_server)
	NetworkHandler.on_client_connected_to_server.connect(on_client_connected_to_server)
	NetworkHandler.on_client_disconnected_from_server.connect(on_client_disconnected_from_server)

func on_client_connected_to_server(id: int) -> void:
	
	$CanvasLayer/Play/VBoxContainer/QueueOnline.disabled = false
	$CanvasLayer/Play/VBoxContainer/QueueOnline.text = "Queue Online"
	update_default_display_name(id)
	set_connection_status(true)

func on_client_disconnected_from_server() -> void:
	$CanvasLayer/Play/VBoxContainer/QueueOnline.disabled = true
	$CanvasLayer/Play/VBoxContainer/QueueOnline.text = "Queue Online"
	
	NetworkHandler.create_client()
	set_connection_status(false)

#region DISPLAY NAME
func set_default_display_name() -> void:
	var display_name: String = Globals.get_saved_display_name()
	if display_name == "":
		
		var id: int = NetworkHandler.multiplayer.get_unique_id()
		display_name = "Guest{0}".format([ id ])
	
	else:
		display_name_set_by_player = true
	
	NetworkHandler.send_server_display_name(display_name)
	$CanvasLayer/Panel2/VBoxContainer/LineEdit.placeholder_text = display_name

func update_default_display_name(id: int) -> void:
	if not display_name_set_by_player:
		
		var display_name = "Guest{0}".format([ id ])
		NetworkHandler.send_server_display_name(display_name)
		$CanvasLayer/Panel2/VBoxContainer/LineEdit.placeholder_text = display_name

func _on_line_edit_text_submitted(new_text: String) -> void:
	
	display_name_set_by_player = true
	NetworkHandler.send_server_display_name(new_text)
	$CanvasLayer/Panel2/VBoxContainer/LineEdit.text = ""
	$CanvasLayer/Panel2/VBoxContainer/LineEdit.placeholder_text = new_text
#endregion


var texture_from_connection: Dictionary = {
	true: load("res://main_menu/icon_checkmark.png"),
	false: load("res://main_menu/icon_cross.png")
}

@onready var connect_status: TextureRect = $CanvasLayer/Panel/VBoxContainer/ConnectionStatus/TextureRect
func set_connection_status(connected: bool) -> void:
	
	connect_status.texture = texture_from_connection[connected]
	if connected:
		connect_status.tooltip_text = "CONNECTED TO SERVER"
	else:
		connect_status.tooltip_text = "NOT CONNECTED TO SERVER"
