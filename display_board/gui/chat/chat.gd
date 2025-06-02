extends Control


@onready var chat_container: VBoxContainer = $VBoxContainer/Control/Control/VBoxContainer

func _ready() -> void:
	if NetworkHandler.is_in_match:
		show()
	else:
		hide()
		$VBoxContainer/Control.mouse_filter = MOUSE_FILTER_IGNORE
		$VBoxContainer/LineEdit.mouse_filter = MOUSE_FILTER_IGNORE
	
	NetworkHandler.on_client_chat_message.connect(on_client_received_chat_message)

func on_client_received_chat_message(chat_message: String) -> void:
	
	var chat_message_label: RichTextLabel = RichTextLabel.new()
	
	chat_message_label.text = chat_message
	chat_message_label.bbcode_enabled = true
	chat_message_label.fit_content = true
	
	chat_container.add_child(chat_message_label)


func _on_line_edit_text_submitted(new_text: String) -> void:
	if new_text == "":
		return
	NetworkHandler.input_chat_message(new_text)
	$VBoxContainer/LineEdit.text = ""


func _on_control_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("scroll_up"):
		scroll_chat(1 * Globals.pixels_per_scroll)
	elif event.is_action_pressed("scroll_down"):
		scroll_chat(-1 * Globals.pixels_per_scroll)

func scroll_chat(pixels: int) -> void:
	
	if chat_container.size.y < $VBoxContainer/Control.size.y:
		return
	
	var pos = chat_container.position.y + pixels
	
	if pos < $VBoxContainer/Control.size.y -  chat_container.size.y:
		pos = $VBoxContainer/Control.size.y - chat_container.size.y
	elif pos > $VBoxContainer/Control.position.y:
		pos = $VBoxContainer/Control.position.y
	
	chat_container.position.y = pos
