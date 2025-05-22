@tool
extends GridContainer
class_name VisualBoard



func set_tile_effect(tile_position: Vector2i, effect: Tile.TILE_EFFECT) -> void:
	tile_array[tile_position.x][tile_position.y].set_tile_effect(effect)

func reset_all_tile_effects() -> void:
	for array_y: Array in tile_array:
		for tile: Tile in array_y:
			tile.set_tile_effect(Tile.TILE_EFFECT.NONE)

var tile_scene: PackedScene = preload("res://board/tile/tile.tscn")
var tile_array: Array[Array]
func _ready() -> void:
	tile_array.resize(columns)
	for array_y: Array in tile_array:
		array_y.resize(columns)
	
	for y: int in range(columns):
		for x: int in range(columns):
			
			var tile: Tile = tile_scene.instantiate()
			
			var is_tile_white: bool = ((x + y) % 2 == 0)
			if is_tile_white:
				tile.color = Color.WHITE
			else:
				tile.color = Color.BLANCHED_ALMOND # lol those almonds
			
			tile.tile_position = Vector2i(x,y)
			
			tile.on_tile_clicked.connect($"..".on_tile_clicked)
			
			tile_array[x][y] = tile
			
			add_child(tile)
