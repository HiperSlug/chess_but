extends Node


@warning_ignore("unused_signal")
signal on_game_end(result: RESULT)

var move_time: float = .2

var pixels_per_scroll: int = 20

enum TYPE {
	PAWN,
	ROOK,
	KNIGHT,
	BISHOP,
	QUEEN,
	KING,
}

enum RESULT {
	WHITE_WIN,
	BLACK_WIN,
	TIE,
}

var texture_dictionary: Dictionary = { # [TYPE][TEAM_IS_WHITE]
	TYPE.PAWN: {
		true: load("res://piece_assets/wP.svg"),
		false: load("res://piece_assets/bP.svg"),
	},
	TYPE.ROOK: {
		true: load("res://piece_assets/wR.svg"),
		false: load("res://piece_assets/bR.svg"),
	},
	TYPE.KNIGHT: {
		true: load("res://piece_assets/wN.svg"),
		false: load("res://piece_assets/bN.svg"),
	},
	TYPE.BISHOP: {
		true: load("res://piece_assets/wB.svg"),
		false: load("res://piece_assets/bB.svg"),
	},
	TYPE.QUEEN: {
		true: load("res://piece_assets/wQ.svg"),
		false: load("res://piece_assets/bQ.svg"),
	},
	TYPE.KING: {
		true: load("res://piece_assets/wK.svg"),
		false: load("res://piece_assets/bK.svg"),
	},
}

var saved_path: String = "save://display_name.res"
func save_display_name(display_name: String) -> void:
	
	var display_name_resource: DisplayName = DisplayName.new(display_name)
	
	ResourceSaver.save(display_name_resource, saved_path)

func get_saved_display_name() -> String:
	
	if ResourceLoader.exists(saved_path, "DisplayName"):
		
		var display_name_resource: DisplayName = ResourceLoader.load(saved_path, "DisplayName")
		
		return display_name_resource.display_name
	
	return ""
