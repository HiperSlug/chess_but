extends Button

var active: bool = false

@export var inactive_texture: Texture
@export var active_texture: Texture

func _ready() -> void:
	NetworkHandler.on_client_match_ended.connect(on_client_match_ended)
	
	if NetworkHandler.is_in_match:
		show()
	else:
		hide()

func on_client_match_ended(_result: Globals.RESULT) -> void:
	disabled = true
	icon = inactive_texture
	modulate = Color.WHITE

func _pressed() -> void:
	if active:
		disabled = true
		modulate = Color.GRAY
		NetworkHandler.forfeit()
	else:
		active = true
		icon = active_texture

func _input(event: InputEvent) -> void:
	if event.is_action_released("select") and not mouse_currently_on_icon:
		active = false
		icon = inactive_texture


var mouse_currently_on_icon = false
func _on_mouse_entered() -> void:
	mouse_currently_on_icon = true


func _on_mouse_exited() -> void:
	mouse_currently_on_icon = false
