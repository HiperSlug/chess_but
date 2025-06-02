extends Control

@export var board_2d: Board2D

func _ready() -> void:
	
	$Panel/BoardControls/RotateBoard.set_board(board_2d)
	$Panel/BoardControls/History.board_2d = board_2d
	
	Globals.on_game_end.connect(on_match_end)


func on_match_end(result: Globals.RESULT) -> void:
	
	
	match result:
		Globals.RESULT.TIE:
			
			create_game_end_popup("TIE")
			
		Globals.RESULT.WHITE_WIN:
			
			create_game_end_popup("WHITE WINS")
			
		Globals.RESULT.BLACK_WIN:
			
			create_game_end_popup("BLACK WINS")

var game_end_popup_scene: PackedScene = preload("res://popups/game_end/game_end_popup.tscn")
func create_game_end_popup(message: String) -> void:
	
	var game_end_popup = game_end_popup_scene.instantiate()
	
	game_end_popup.set_message(message)
	
	add_child(game_end_popup)
	
	await get_tree().create_timer(1).timeout
	
	game_end_popup.queue_free()
