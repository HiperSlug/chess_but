extends Node2D
class_name Tile

const tile_size: int = 64

var tile_position: Vector2i

signal on_tile_pressed(tile_position: Vector2i)
signal on_tile_released(tile_position: Vector2i)
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("select"):
		on_tile_pressed.emit(tile_position)
	elif event.is_action_released("select"):
		on_tile_released.emit(tile_position)

func set_color(color: Color) -> void:
	$Tile.modulate = color

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
			$SelectionDot.hide()
		TILE_EFFECT.SELECTED:
			modulate = Color("#186484")
			$SelectionDot.hide()
		TILE_EFFECT.MOVE:
			modulate = Color.WHITE 
			$SelectionDot.show()
			$SelectionDot.modulate = Color.GRAY
		TILE_EFFECT.CAPTURE:
			modulate = Color.WHITE 
			$SelectionDot.show()
			$SelectionDot.modulate = Color.RED
	
	tile_effect = new_tile_effect


func set_enabled(enabled: bool) -> void:
	$Area2D/CollisionShape2D.set_deferred("disabled", not enabled)
