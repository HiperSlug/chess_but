extends TextureRect

var active: bool = false

@export var inactive_texture: Texture
@export var active_texture: Texture

func _ready() -> void:
	if NetworkHandler.is_in_match:
		show()
	else:
		hide()

func _on_button_pressed() -> void:
	if active:
		$Button.disabled = true
		modulate = Color.GRAY
		NetworkHandler.forfeit.rpc_id(1, NetworkHandler.current_match_id, NetworkHandler.multiplayer.get_unique_id())
	else:
		active = true
		texture = active_texture

func _input(event: InputEvent) -> void:
	if event.is_action_released("select") and not mouse_currently_on_icon:
		active = false
		texture = inactive_texture


var mouse_currently_on_icon = false
func _on_mouse_entered() -> void:
	mouse_currently_on_icon = true


func _on_mouse_exited() -> void:
	mouse_currently_on_icon = false
