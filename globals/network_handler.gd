extends Node


func _ready() -> void:
	
	if OS.has_feature("server"):
		create_server()
	else:
		create_client()

## If launch arguments has argument "--server=true" then this instance of the game will host itself as a server, otherwise it will host itself as a client.
## Called by _ready() function.
func determine_if_server_from_arguments() -> void:
	
	var arguments: Dictionary = {}
	
	# parse arguments
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			arguments[argument.trim_prefix("--")] = ""
	
	# determine if server
	if arguments.has("server") and arguments["server"] == "true":
		create_server()
	else:
		create_client()


#region SERVER CONNECTION

## Client variable.
## Used by mainmenu to give default display_names
signal on_client_connected_to_server(client_id: int)

## Client variable.
## Used in mainmenu to display connecttion status
signal on_client_disconnected_from_server()

## Client variable.
## If client is connected to the server.
var is_client_connected_to_server: bool = false

var PORT: int = 1111
var bind_address: String = "0.0.0.0"
var URL: String = "wss://chess-but.onrender.com"

var http_server: TCPServer

## Sets the game instance as a server.
## Connects the server to connected and disconnected signals.
## Port 80.
func create_server() -> void:
	
	print("hosting")
	
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_server(PORT, bind_address)
	print(PORT)
	print(bind_address)
	multiplayer.multiplayer_peer = peer
	
	peer.peer_connected.connect(on_peer_connected)
	peer.peer_disconnected.connect(on_peer_disconnected)

## Sets the game instance as a client.
## Connects it to the url in the URL constant.
func create_client() -> void:
	
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_client(URL)
	multiplayer.multiplayer_peer = peer
	
	peer.peer_connected.connect(on_peer_connected)
	peer.peer_disconnected.connect(on_peer_disconnected)

## Client and server function.
## Client uses this to know when to give the server its display name.
func on_peer_connected(id: int) -> void:
	
	if id == 1:
		var client_id: int = multiplayer.get_unique_id()
		is_client_connected_to_server = true
		
		on_client_connected_to_server.emit(client_id)
	
	else:
		
		print("{0}: connected".format([id]))

## Server and client function.
## Removes player from anything they were in, both on the server and on the client.
func on_peer_disconnected(id: int) -> void:
	
	if id == 1:
		
		is_in_match = false
		client_match_id = 0
		get_tree().change_scene_to_file("res://main_menu/main_menu.tscn")
		
		is_client_connected_to_server = false
		
		on_client_disconnected_from_server.emit()
	
	else:
	
		print("{0}: disconnected".format([id]))
		
		if id in players_queuing:
			players_queuing.erase(id)
		
		for match_id: int in matches.keys():
			
			var match_info_array: Array = matches[match_id]
			
			if match_info_array[0] == id or match_info_array[1] == id:
				remove_player_from_match(match_id, id)



#endregion


#region SERVER MATCH MAKING
## Server variable.
## An array of the ids of all queued players.
var players_queuing: Array[int] = []

## Client function
## calls rpc client_to_server_queue_for_game with player_id
func queue_for_game() -> void:
	if is_client_connected_to_server:
		var player_id: int = multiplayer.get_unique_id()
		client_to_server_queue_for_game.rpc_id(1, player_id)

## @rpc client -> server.
## Gives server the client id, which server uses to add player to players_queuing.
## Runs the match_making() function whenever a player joins.
@rpc("any_peer", "reliable")
func client_to_server_queue_for_game(player_id: int) -> void:
	
	print("{0}: queued".format([player_id]))
	
	players_queuing.append(player_id)
	
	match_making()

## Client function
## calls rpc client_to_server_dequeue_for_game with player_id
func dequeue_for_game() -> void:
	if is_client_connected_to_server:
		var player_id: int = multiplayer.get_unique_id()
		client_to_server_dequeue_for_game.rpc_id(1, player_id)

## @rpc client -> server.
## Gives server the client id, which server uses to remove player from players_queuing.
@rpc("any_peer", "reliable")
func client_to_server_dequeue_for_game(player_id: int) -> void:
	
	print("{0}: dequeued".format([player_id]))
	
	players_queuing.erase(player_id)

## Server function.
## If there is an available match in players_queuing, currently an available match just means if two people have queued, then it/
## creates a match and removes the players from the queue.
func match_making() -> void:
	
	if players_queuing.size() >= 2:
		
		# Randomly determining who is white.
		var player_1_is_white: bool = (randi() % 2 == 0)
		
		create_match(players_queuing[0], players_queuing[1], player_1_is_white)
		
		# removing players from queue
		players_queuing.remove_at(0)
		players_queuing.remove_at(0)

## Server variable.
## A Dictionary: match_id -> match_info_array. 
## The match_info_array has the following format:
## [0] - white player id
## [1] - black player id
## [2] - reference to chess game node
## [3] - white player offering tie
## [4] - black player offering tie
var matches: Dictionary[int, Array] = {}

## Used to instantiate ChessGame per match on the server.
## Also used by the client when starting a game for the switch_scene_to_packed() call.
var chess_game_scene: PackedScene = preload("res://chess_game/chess_game.tscn") # Find proper location for this variable

## Server function.
## Initalizes a serverside chess game.
## Stores match_info_array in matches Dictionary. 
## The match_info_array has the following format:
## [0] - white player id
## [1] - black player id
## [2] - reference to chess game node
## Finally it tells the players that they have joined a match with rpc server_to_client_start_match
func create_match(player_1_id: int, player_2_id: int, player_1_is_white: bool) -> void:
	
	var match_id: int = get_unique_match_id()
	
	# instantiate a game server side
	var chess_game: ChessGame = chess_game_scene.instantiate()
	add_child(chess_game)
	
	# initalizing match_info_array
	var match_info_array: Array = []
	match_info_array.resize(5)
	
	# index 2 is the chess_game node
	match_info_array[2] = chess_game
	
	# index 0 is the white player
	# index 1 is the black player
	if player_1_is_white:
		match_info_array[0] = player_1_id
		match_info_array[1] = player_2_id
	else:
		match_info_array[0] = player_2_id
		match_info_array[1] = player_1_id
	
	# offering tie
	match_info_array[3] = false
	match_info_array[4] = false
	
	matches[match_id] = match_info_array
	
	server_to_client_start_match.rpc_id(match_info_array[0], match_id, true)
	server_to_client_start_match.rpc_id(match_info_array[1], match_id, false)

## Server variable.
## When getting a unique match id this variable is used, then iterated by one.
var match_id_iterator: int = 0

## Server function.
## Adds one to the current match_id_iterator value then returns it as a unique id.
func get_unique_match_id() -> int:
	match_id_iterator += 1
	return match_id_iterator
#endregion


#region CLIENT MATCH JOINING
## Client variable.
## Used by other processes to determine unique behavior when playing online.
var is_in_match: bool = false:
	set(value):
		is_in_match = value
		is_in_match_changed.emit(is_in_match)

## Client signal.
## Emitted upon change to is_in_match.
## This is only used by the main menu button, and may be removed if main menu functionality changes.
signal is_in_match_changed(new_value: bool)

## Client variable.
## This variable is given to the client by the server upon starting a match.
## Whenever the client sends a GAME SPECIFIC RPC to the server it must also send it's match_id so/
## the server can identify which match it is in.
var client_match_id: int = 0

## Client variable.
## This variable is given to the client by the server upon starting a match.
## This variable is used to determine if the match has been won or lost.
## This variable is also used by processes to determine if certain things are allowed, for/
## example moving a piece of the opposing team.
var team_is_white: bool = true

## @rpc server -> client.
## Sets inportant match information, match_id and team, then runs the chess_game scene.
@rpc("authority", "reliable")
func server_to_client_start_match(match_id: int, team_is_white_: bool) -> void:
	
	# initalize variables
	is_in_match = true
	client_match_id = match_id
	team_is_white = team_is_white_
	
	# start game
	get_tree().change_scene_to_packed(chess_game_scene)
#endregion


#region SENDING AND RECEIVING MOVES
## Client function.
## Serializes move, then sends it to server using client_to_server_move rpc with all required information.
func send_server_move(move: Move) -> void:
	
	var move_dict: Dictionary = move.serialize()
	var player_id: int = multiplayer.get_unique_id()
	
	client_to_server_validate_move.rpc_id(1, client_match_id, player_id, move_dict)

## @rpc client -> server.
## Uses the match id to ask the associated chess game if the move is valid.
## If it is not valid then it does nothing, either someone cheated or there was a bug.
## If it was a valid move then server side it completes the move, then it tells the clients to complete the move/
## using rpc server_to_client_completed_move
@rpc("any_peer", "reliable")
func client_to_server_validate_move(match_id: int, player_id: int, move_dict: Dictionary) -> void:
	
	var match_info_array: Array = matches[match_id]
	
	var player_team_is_white: bool = (match_info_array[0] == player_id)
	var chess_game: ChessGame = match_info_array[2]
	
	var move: Move = Move.deserialize(move_dict)
	
	var is_valid_move: bool = chess_game.is_move_valid(move, player_team_is_white)
	if is_valid_move:
		
		chess_game.complete_move(move)
		
		
		server_to_client_completed_move.rpc_id(match_info_array[0], move_dict)
		server_to_client_completed_move.rpc_id(match_info_array[1], move_dict)
		
		var result = chess_game.check_for_match_end(not player_team_is_white)
		if result != null:
			
			end_match(match_id, result)

## Client signal.
## Ferrys information about completed moves to ChessGame so that it can update the clients board.
signal on_client_complete_move(move: Move)

## @rpc server -> client.
## Deserialzies the received move then emits a signal connected to the chessgame which completes the move client side.
@rpc("authority", "reliable")
func server_to_client_completed_move(move_dict: Dictionary) -> void:
	
	var move: Move = Move.deserialize(move_dict)
	on_client_complete_move.emit(move)
#endregion


#region CHAT
## Client function.
## Calls rpc client_to_server_input_chat_message with all neccecary information.
func input_chat_message(chat_message: String) -> void:
	
	var player_id: int = multiplayer.get_unique_id()
	client_to_server_input_chat_message.rpc_id(1, client_match_id, player_id, chat_message)

## @rpc client -> server.
## Wraps the chat message in the players display name.
## Tells all clients associated with the match about the chat message.
@rpc("any_peer","reliable")
func client_to_server_input_chat_message(match_id: int, player_id: int, chat_message: String) -> void:
	
	var match_info_array: Array = matches[match_id]
	
	var display_name: String = player_id_to_display_name_dictionary[player_id]
	var wrapped_chat_message: String = "[color=#2596be]{0}:[/color] [color=black]{1}[/color]".format([display_name, chat_message])
	
	if match_info_array[0] != 0:
		
		server_to_client_chat_message.rpc_id(match_info_array[0], wrapped_chat_message)
	
	if match_info_array[1] != 0:
		
		server_to_client_chat_message.rpc_id(match_info_array[1], wrapped_chat_message)

## Server function.
## Sends the message to all clients in match raw.
func send_server_message(match_id: int, message: String) -> void:
	
	var match_info_array: Array = matches[match_id]
	
	var formated_message: String = "[color=#186484]" + message
	
	if match_info_array[0] != 0:
		
		server_to_client_chat_message.rpc_id(match_info_array[0], formated_message)
	
	if match_info_array[1] != 0:
		
		server_to_client_chat_message.rpc_id(match_info_array[1], formated_message)

## Client signal.
## Ferrys chat to chat gui.
signal on_client_chat_message(chat: String)

## @rpc server -> client.
## Receives a chat message from the server. 
## Emits on_client_chat_message to be received by chat gui.
@rpc("authority", "reliable")
func server_to_client_chat_message(chat: String) -> void:
	on_client_chat_message.emit(chat)
#endregion


#region MATCH END AND FORFEIT
## Server function.
## Sends the result to all clients in the match, then gets rid of the associated ChessGame object.
func end_match(match_id: int, result: Globals.RESULT) -> void:
	
	var match_info_array: Array = matches[match_id]
	
	if match_info_array[0] != 0:
		server_to_client_match_ended.rpc_id(match_info_array[0], result)
	
	if match_info_array[1] != 0:
		server_to_client_match_ended.rpc_id(match_info_array[1], result)
	
	match result:
		Globals.RESULT.WHITE_WIN:
			send_server_message(match_id, "MATCH OVER: WHITE WINS")
		Globals.RESULT.BLACK_WIN:
			send_server_message(match_id, "MATCH OVER: BLACK WINS")
		Globals.RESULT.TIE:
			send_server_message(match_id, "MATCH OVER: DRAW")
	
	
	
	var chess_game: ChessGame = match_info_array[2]
	chess_game.queue_free()
	
	match_info_array[2] = null

## Client signal
signal on_client_match_ended(result: Globals.RESULT)

## @rpc server -> client
## Emits the match results and exits the match state.
@rpc("authority", "reliable")
func server_to_client_match_ended(result: int) -> void:
	
	result = result as Globals.RESULT
	
	Globals.on_game_end.emit(result)
	on_client_match_ended.emit(result)
	
	is_in_match = false


## Client function.
## Sends rpc client_to_server_forfeit to server with associated information.
func forfeit() -> void:
	
	var player_id: int = multiplayer.get_unique_id()
	client_to_server_forfeit.rpc_id(1, client_match_id, player_id)

## @rpc client -> server.
## Determines which team forfeited then ends the game with the opposite team as a winner.
@rpc("any_peer", "reliable")
func client_to_server_forfeit(match_id: int, player_id: int) -> void:
	
	var match_info_array: Array = matches[match_id]
	var forfeited_team_is_white = (match_info_array[0] == player_id)
	
	var match_result: Globals.RESULT
	if forfeited_team_is_white:
		match_result = Globals.RESULT.BLACK_WIN
	else:
		match_result = Globals.RESULT.WHITE_WIN
	
	send_server_message(match_id, "{0} has conceeded".format([player_id_to_display_name_dictionary[player_id]]))
	
	end_match(match_id, match_result)

## Client function.
## Calls rpc client_to_server_leave_match with associated variables and sets match status.
func leave_match() -> void:
	var player_id: int = multiplayer.get_unique_id()
	
	client_to_server_leave_match.rpc_id(1, client_match_id, player_id)
	
	is_in_match = false
	client_match_id = 0

## @rpc client -> server.
## Calls server function remove_player_from_match.
## The remove_player_from_match is a separate function so that other locations can easily call it.
@rpc("any_peer", "reliable")
func client_to_server_leave_match(match_id: int, player_id: int) -> void:
	remove_player_from_match(match_id, player_id)


## Server function.
## Figures out who left and removed them from the match info.
## If they were the last player in a match then it deletes the match entierly.
func remove_player_from_match(match_id: int, player_id: int) -> void:
	var match_info_array: Array = matches[match_id]
	var white_player_in_match: bool = match_info_array[0] != 0
	var black_player_in_match: bool = match_info_array[1] != 0
	
	# if the leaving player is white
	if white_player_in_match and match_info_array[0] == player_id:
		
		match_info_array[0] = 0
		
		var display_name: String = player_id_to_display_name_dictionary[player_id]
		send_server_message(match_id, "{0} has left".format([display_name]))
		
		if not black_player_in_match:
			matches.erase(match_id)
	
	# if the leaving player is black
	elif black_player_in_match and match_info_array[1] == player_id:
		
		match_info_array[1] = 0
		
		var display_name: String = player_id_to_display_name_dictionary[player_id]
		send_server_message(match_id, "{0} has left".format([display_name]))
		
		if not white_player_in_match:
			matches.erase(match_id)

## Client function
## Calls rpc client_to_server_offer_tie with match id and player id
func offer_tie() -> void:
	var player_id: int = multiplayer.get_unique_id()
	client_to_server_offer_tie.rpc_id(1, client_match_id, player_id)

## @rpc client -> server.
## Set player as offering tie, sends chat message, then if both players offer at the same time end the match
@rpc("any_peer", "reliable")
func client_to_server_offer_tie(match_id: int, player_id: int) -> void:
	
	var match_info_array: Array = matches[match_id]
	
	var is_player_white: bool = match_info_array[0] == player_id
	
	if is_player_white:
		
		match_info_array[3] = true
		
	
	else:
		
		match_info_array[4] = true
	
	if match_info_array[3] == true and match_info_array[4] == true:
		
		send_server_message(match_id, "{0} has accepted a draw".format([player_id_to_display_name_dictionary[player_id]]))
		
		end_match(match_id, Globals.RESULT.TIE)
	
	else:
		
		send_server_message(match_id, "{0} has offered a draw".format([player_id_to_display_name_dictionary[player_id]]))

## Client function
## Calls rpc client_to_server_remove_draw_offer with ids.
func remove_tie_offer() -> void:
	var player_id: int = multiplayer.get_unique_id()
	client_to_server_remove_draw_offer.rpc_id(1, client_match_id, player_id)


## @rpc client -> server.
## Removes draw offer, sends chat message.
@rpc("any_peer", "reliable")
func client_to_server_remove_draw_offer(match_id: int, player_id: int) -> void:
	
	var match_info_array: Array = matches[match_id]
	
	var is_player_white: bool = match_info_array[0] == player_id
	
	if is_player_white:
		
		match_info_array[3] = false
		
	else:
		
		match_info_array[4] = false
	
	send_server_message(match_id, "{0} has stopped offering a draw".format([player_id_to_display_name_dictionary[player_id]]))


#endregion


#region DISPLAY NAME
## Serer variable.
## Used for chatting to address chats.
var player_id_to_display_name_dictionary: Dictionary[int, String] = {}

## Client function.
## Calls rpc client_to_server_display_name to server sending it the display name.
func send_server_display_name(display_name: String) -> void:
	if is_client_connected_to_server:
		var player_id: int = multiplayer.get_unique_id()
		client_to_server_display_name.rpc_id(1, player_id, display_name)

## @rpc client -> server
## Sets player_id_to_display_name_dictionary value for the player.
@rpc("any_peer", "reliable")
func client_to_server_display_name(player_id: int, display_name: String) -> void:
	player_id_to_display_name_dictionary[player_id] = display_name
#endregion
