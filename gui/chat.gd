extends ColorRect


func _ready() -> void:
	if NetworkHandler.is_in_match:
		show()
	
	NetworkHandler.on_network_chat_received.connect(on_chat_received)

func on_chat_received(chat: String, display_name: String) -> void:
	
	var chat_message: RichTextLabel = RichTextLabel.new()
	chat_message.text = "{0}: {1}\n".format([display_name, chat])
	chat_message.bbcode_enabled = true
	chat_message.fit_content = true
	chat_container.add_child(chat_message)


func _on_line_edit_text_submitted(new_text: String) -> void:
	NetworkHandler.send_chat_to_server.rpc_id(1, NetworkHandler.current_match_id, new_text, NetworkHandler.display_name)
	$VBoxContainer/LineEdit.text = ""


func _on_control_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		scroll_chat(1)
	elif event.is_action_pressed("scroll_down"):
		scroll_chat(-1)

var chat_scroll_pixels: int = 10
@onready var chat_container: VBoxContainer = $VBoxContainer/Control/VBoxContainer
func scroll_chat(direction_y: int) -> void:
	
	if chat_container.size.y < $VBoxContainer/Control.size.y:
		return
	
	var pos = chat_container.position.y + direction_y * chat_scroll_pixels
	
	if pos < $VBoxContainer/Control.size.y -  chat_container.size.y:
		pos = $VBoxContainer/Control.size.y - chat_container.size.y
	elif pos > $VBoxContainer/Control.position.y:
		pos = $VBoxContainer/Control.position.y
	
	chat_container.position.y = pos
