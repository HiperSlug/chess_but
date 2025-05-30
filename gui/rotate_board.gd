@tool
extends TextureRect


var white_side_active: bool = true
@export var white_texture: Texture
@export var black_texture: Texture

func _ready() -> void:
	update_texture()
	Globals.on_board_rotated.connect(on_board_set_white_side_active)
	if NetworkHandler.is_in_match:
		on_board_set_white_side_active(NetworkHandler.team_is_white)

func on_board_set_white_side_active(team_is_white: bool) -> void:
	white_side_active = team_is_white
	update_texture()

func update_texture() -> void:
	
	if not white_side_active:
		texture = white_texture
	else:
		texture = black_texture

func _on_button_pressed() -> void:
	white_side_active = not white_side_active
	Globals.on_input_tells_board_rotate.emit(white_side_active)
	update_texture()
