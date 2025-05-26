extends Node2D
class_name Piece2D

var display_icon_scene: PackedScene = preload("res://move_sets/icon/move_set_icon.tscn")

func _ready() -> void:
	update_texture()
	
	for move_set: MoveSet in piece.move_sets:
		add_move_set_icon(move_set)

func update_texture() -> void:
	$Sprite2D.texture = Globals.texture_dictionary[piece.type][piece.team_is_white]

var move_set_icons: Array[MoveSetIcon]
func add_move_set_icon(move_set: MoveSet) -> void:
	var display_icon = display_icon_scene.instantiate()
		
	display_icon.move_set = move_set
	
	move_set_icons.append(display_icon)
	$Sprite2D/HBoxContainer.add_child(display_icon)


var piece: Piece
func set_piece(_piece) -> void:
	piece = _piece
	piece.added_move_set.connect(on_piece_added_move_set)
	piece.removed_move_set.connect(on_piece_removed_move_set)
	piece.type_changed.connect(on_piece_type_changed)

func on_board_piece_position_changed(_piece: Piece, new_position: Vector2i) -> void:
	if piece == _piece:
		position.x = Tile.tile_size * (new_position.x - 4)
		position.y = Tile.tile_size * (new_position.y - 4)

func on_board_piece_removed(_piece: Piece) -> void:
	if piece == _piece:
		queue_free()


func on_piece_added_move_set(move_set: MoveSet) -> void:
	add_move_set_icon(move_set)

func on_piece_removed_move_set(move_set: MoveSet) -> void:
	for move_set_icon: MoveSetIcon in move_set_icons:
		if move_set_icon.move_set == move_set:
			move_set_icons.erase(move_set_icon)
			move_set_icon.queue_free()

func on_piece_type_changed() -> void:
	update_texture()

var following_mouse: bool = false
var relative_position: Vector2 = Vector2.ZERO
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		following_mouse = true
		relative_position = global_position - get_global_mouse_position()

func _input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		following_mouse = false
		$Sprite2D.position = Vector2.ZERO


func _process(_delta: float) -> void:
	if following_mouse:
		$Sprite2D.global_position = get_global_mouse_position() + relative_position
