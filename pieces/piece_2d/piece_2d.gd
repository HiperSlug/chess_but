extends Node2D
class_name Piece2D

var display_icon_scene: PackedScene = preload("res://move_sets/icon/move_set_icon.tscn")

func _ready() -> void:
	update_texture()
	
	for move_set: MoveSet in piece.move_sets:
		add_move_set_icon(move_set)
	
	Globals.set_mouse_pickable_enabled.connect(set_enabled)

func set_enabled(enabled: bool) -> void:
	$Area2D/CollisionShape2D.set_deferred("disabled", not enabled)


func update_texture() -> void:
	$Sprite2D.texture = Globals.texture_dictionary[piece.type][piece.team_is_white]

var move_set_icons: Array[MoveSetIcon]
func add_move_set_icon(move_set: MoveSet) -> void:
	var display_icon = display_icon_scene.instantiate()
	
	display_icon.move_set = move_set
	display_icon.set_type(move_set.type)
	
	move_set_icons.append(display_icon)
	$Sprite2D/Control/HBoxContainer.add_child(display_icon)


var piece: Piece
func set_piece(_piece) -> void:
	piece = _piece
	piece.added_move_set.connect(on_piece_added_move_set)
	piece.removed_move_set.connect(on_piece_removed_move_set)
	piece.type_changed.connect(on_piece_type_changed)
	piece.get_promotion_type.connect(on_piece_get_promotion_type)

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

var pixels_per_scroll: float = 10

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		following_mouse = true
		relative_position = global_position - get_global_mouse_position()
	
	if event.is_action("scroll_up"):
		scroll_through_move_sets(-1 * pixels_per_scroll)
	
	if event.is_action("scroll_down"):
		scroll_through_move_sets(pixels_per_scroll)

func scroll_through_move_sets(pixels: float) -> void:
	var move_set_container: Node = $Sprite2D/Control/HBoxContainer
	if move_set_container.size.x < 100:
		return
	var pos_container: float = move_set_container.position.x
	var pos_x: float = pos_container + pixels
	pos_x = clampf(pos_x, - move_set_container.size.x + 100.0, 0.0) 
	move_set_container.position = Vector2(pos_x, move_set_container.position.y)

func _input(event: InputEvent) -> void:
	if event.is_action_released("select"):
		following_mouse = false
		$Sprite2D.position = Vector2.ZERO


func _process(_delta: float) -> void:
	if following_mouse:
		$Sprite2D.global_position = get_global_mouse_position() + relative_position

var promotion_popup_scene: PackedScene = preload("res://popups/promotion/promotion_popup.tscn")

var promotion_popup_relative_position_white: Vector2i = Vector2i(32,96)
var promotion_popup_relative_position_black: Vector2i = Vector2i(32,-32)
func on_piece_get_promotion_type() -> void:
	var promotion_popup: Node = promotion_popup_scene.instantiate()
	promotion_popup.set_team(piece.team_is_white)
	
	if piece.team_is_white:
		promotion_popup.position = promotion_popup_relative_position_white
	else:
		promotion_popup.position = promotion_popup_relative_position_black
	
	add_child(promotion_popup)
	var chosen_move_set_type: Globals.TYPE = await promotion_popup.move_set_chosen
	
	piece.promote(chosen_move_set_type)
	
	promotion_popup.queue_free()
