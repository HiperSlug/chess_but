extends Panel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not NetworkHandler.is_in_match:
		hide()
