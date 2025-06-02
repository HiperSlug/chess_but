extends Button

var board_2d: Board2D
var white_side_active: bool = true
@export var white_texture: Texture
@export var black_texture: Texture


func _ready() -> void:
	update_texture()
	
	if NetworkHandler.is_in_match:
		on_board_2d_rotated(NetworkHandler.team_is_white)


func set_board(set_board_2d: Board2D) -> void:
	board_2d = set_board_2d
	board_2d.on_board_2d_rotated.connect(on_board_2d_rotated)
	on_rotate_pressed.connect(board_2d.rotate_board)

func update_texture() -> void:
	
	if not white_side_active:
		icon = white_texture
	else:
		icon = black_texture

signal on_rotate_pressed(new_active_team: bool)

func _pressed() -> void:
	white_side_active = not white_side_active
	on_rotate_pressed.emit(white_side_active)
	update_texture()


func on_board_2d_rotated(team_is_white: bool) -> void:
	white_side_active = team_is_white
	update_texture()
