extends TextureRect



@export var type: Globals.TYPE = Globals.TYPE.QUEEN
@export var team_is_white: bool = false


func _ready() -> void:
	texture = Globals.texture_dictionary[type][team_is_white]
