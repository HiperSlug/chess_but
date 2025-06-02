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

func _toggled(toggled_on: bool) -> void:
	if toggled_on:
		icon = active_texture
		NetworkHandler.offer_tie()
	
	else:
		icon = inactive_texture
		NetworkHandler.remove_tie_offer()
