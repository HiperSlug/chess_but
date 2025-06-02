extends HBoxContainer

var chess_game: ChessGame
var board_2d: Board2D

var history_position: int = -1

var in_history_mode: bool = false

func _ready() -> void:
	
	if NetworkHandler.is_in_match:
		NetworkHandler.on_client_complete_move.connect(on_client_complete_move)
	
	Globals.on_game_end.connect(on_game_end)
	
	$Current.disabled = true
	$Next.disabled = true
	$Back.disabled = true
	
	await chess_game.turn_changed
	
	$Back.disabled = false

var can_start_moves_when_leaving_history_mode: bool = true
func on_game_end(_result: Globals.RESULT) -> void:
	can_start_moves_when_leaving_history_mode = false

func on_client_complete_move(_move: Move) -> void:
	
	if in_history_mode:
		
		$AnimationPlayer.play("flash_current")


func _on_back_pressed() -> void:
	
	if not in_history_mode:
		enter_history_mode()
	
	history_position -= 1
	
	display_historic_board()
	check_if_buttons_should_be_disabled()


func _on_next_pressed() -> void:
	
	history_position += 1
	if history_position >= chess_game.board_history.size():
		exit_history_mode()
		check_if_buttons_should_be_disabled()
		return
	
	display_historic_board()
	check_if_buttons_should_be_disabled()


func _on_current_pressed() -> void:
	exit_history_mode()
	check_if_buttons_should_be_disabled()


func enter_history_mode() -> void:
	$Timer.start()
	in_history_mode = true
	
	history_position = chess_game.board_history.size()
	
	board_2d.can_input_moves = false


func exit_history_mode() -> void:
	$Timer.stop()
	in_history_mode = false
	
	history_position = chess_game.board_history.size() - 1
	if can_start_moves_when_leaving_history_mode:
		board_2d.can_input_moves = true
	
	board_2d.board = chess_game.board
	
	board_2d.clear_board_pieces()
	board_2d.setup_board_pieces()
	
	$AnimationPlayer.stop()


func display_historic_board() -> void:
	var historic_board: Board = chess_game.board_history[history_position]
	
	board_2d.board = historic_board
	
	board_2d.clear_board_pieces()
	board_2d.setup_board_pieces()


func check_if_buttons_should_be_disabled() -> void:
	
	if in_history_mode:
		
		$Current.disabled = false
		$Next.disabled = false
		
		var can_go_back: bool = (history_position > 0)
		
		$Back.disabled = not can_go_back
		
	else:
		
		$Back.disabled = false
		$Current.disabled = true
		$Next.disabled = true


func _on_timer_timeout() -> void:
	$AnimationPlayer.play("flash_current")
