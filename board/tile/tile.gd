@tool
extends ColorRect
class_name Tile

signal on_tile_clicked(tile_position: Vector2i)

var tile_position: Vector2i

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		accept_event() # may need to remove if it conflicts with pieces.
		on_tile_clicked.emit(tile_position)

enum TILE_EFFECT {
	NONE,
	SELECTED,
	MOVE,
	CAPTURE,
}
var tile_effect: TILE_EFFECT = TILE_EFFECT.NONE

func set_tile_effect(new_tile_effect: TILE_EFFECT) -> void:
	match new_tile_effect: # Obviously can do more complicated shit with this.
		TILE_EFFECT.NONE:
			modulate = Color.WHITE 
		TILE_EFFECT.SELECTED:
			modulate = Color.BLUE
		TILE_EFFECT.MOVE:
			modulate = Color.GRAY
		TILE_EFFECT.CAPTURE:
			modulate = Color.RED
	tile_effect = new_tile_effect
