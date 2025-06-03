extends Node2D
class_name Piece2D

var move_set_icon_scene: PackedScene = preload("res://moves/move_set_icon.tscn")

func _ready() -> void:
	update_texture()


## Sets the texture based on local variables and the Globals.texutre_dictionary
func update_texture() -> void:
	$Sprite2D.texture = Globals.texture_dictionary[piece.type][piece.team_is_white]


## Contains all move set icon nodes
var move_set_icons: Array[MoveSetIcon]

## Creates a new move set icon and adds it to the container.
## initalizies its variables so it displays the correct move set
func add_move_set_icon(move_set: MoveSet) -> void:
	var move_set_icon = move_set_icon_scene.instantiate()
	
	move_set_icon.move_set = move_set
	move_set_icon.set_type(move_set.type)
	
	move_set_icons.append(move_set_icon)
	$Sprite2D/Control/HBoxContainer.add_child(move_set_icon)

#region PIECE 
## Whenever this piece changes the piece2d needs to mimic it.
var piece: Piece

## Connects signals to piece and initalizes it's move set icons
func set_piece(_piece) -> void:
	piece = _piece
	
	for move_set: MoveSet in piece.move_sets:
		add_move_set_icon(move_set)
	
	# connect signals
	piece.added_move_set.connect(on_piece_added_move_set)
	piece.removed_move_set.connect(on_piece_removed_move_set)
	piece.type_changed.connect(on_piece_type_changed)

## Connected to signal in piece
## Adds a move set icon with the new moveset
func on_piece_added_move_set(move_set: MoveSet) -> void:
	add_move_set_icon(move_set)

## Connected to signal in piece
## Locates move_set_icon with associated move set and removes it
func on_piece_removed_move_set(move_set: MoveSet) -> void:
	for move_set_icon: MoveSetIcon in move_set_icons:
		if move_set_icon.move_set == move_set:
			move_set_icons.erase(move_set_icon)
			move_set_icon.queue_free()

## Connected to signal in piece
func on_piece_type_changed(_new_type: Globals.TYPE) -> void:
	update_texture()
#endregion


#region BOARD SIGNALS
## Function connected to board on_piece_position_changed by board_2d
## This is called in every piece2d every time something changes.
## This interpolates the position of the piece to the final_position over Globals.move_time
## This also changes the z_sort index so that this piece will appear on top of other pieces
## Pieces will move faster if they are moving farther.
func on_board_piece_position_changed(changed_piece: Piece, new_matrix_position: Vector2i) -> void:
	if piece == changed_piece:
		
		var tween: Tween = get_tree().create_tween()
		
		var fin_x: float = Tile.tile_size * (new_matrix_position.x - 3.5)
		var fin_y: float = Tile.tile_size * (new_matrix_position.y - 3.5)
		var final_position: Vector2 = Vector2(fin_x, fin_y)
		
		z_index += 1
		
		tween.tween_property(self, "position", final_position, Globals.move_time)
		
		await tween.finished
		z_index -= 1

## After the move_time is finished this removes the piece_2d.
func on_board_piece_removed(removed_piece: Piece) -> void:
	if piece == removed_piece:
		await get_tree().create_timer(Globals.move_time).timeout
		queue_free()
#endregion


#region DRAGGING AND SCROLLING
## Takes three inputs:
## Select -> follow mouse
## Scroll_up and scroll down -> Scroll through the move set icon container
## 
## When following the mouse the mouse goes off of the piece2d so it receives it's deselct in the input function instead of here.
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		following_mouse = true
		z_index += 1
		relative_position = global_position - get_global_mouse_position()
	
	if event.is_action("scroll_up"):
		scroll_through_move_sets(-1 * Globals.pixels_per_scroll)
	
	if event.is_action("scroll_down"):
		scroll_through_move_sets(Globals.pixels_per_scroll)

## If event is deselect then stop following the mouse
func _input(event: InputEvent) -> void:
	if event.is_action_released("select") and following_mouse:
		following_mouse = false
		z_index -= 1
		$Sprite2D.position = Vector2.ZERO

## Moves the move set container right and left based on the input parameter
## Stops scrolling at the edges
func scroll_through_move_sets(pixels: float) -> void:
	
	var move_set_container: Node = $Sprite2D/Control/HBoxContainer
	if move_set_container.size.x < 100:
		return
	
	var pos_container: float = move_set_container.position.x
	var pos_x: float = pos_container + pixels
	
	pos_x = clampf(pos_x, - move_set_container.size.x + 100.0, 0.0) 
	
	move_set_container.position = Vector2(pos_x, move_set_container.position.y)


## When starting following the mouse the relative position to the mouse is sustained through this variable.
var relative_position: Vector2 = Vector2.ZERO
var following_mouse: bool = false

## If following mouse then move the sprite to the position
## Only the sprite goes this is a visual change, all actual input stuff is handled in the board2d.
func _process(_delta: float) -> void:
	if following_mouse:
		$Sprite2D.global_position = get_global_mouse_position() + relative_position
#endregion
