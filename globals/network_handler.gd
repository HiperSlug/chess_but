extends Node


func _ready() -> void:
	var arguments: Dictionary = {}
	for argument in OS.get_cmdline_args():
		if argument.contains("="):
			var key_value = argument.split("=")
			arguments[key_value[0].trim_prefix("--")] = key_value[1]
		else:
			arguments[argument.trim_prefix("--")] = ""
	if arguments.has("server") and arguments["server"] == "true":
		create_server(PORT)
	else:
		create_client(URL)
	
	
	pass


#region SERVER CONNECTION


var PORT: int = 4000
var URL: String = "ws://localhost:{0}".format([PORT])
var local_host: String = "127.0.0.1"
func create_server(port: int) -> void:
	
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_server(port, local_host)
	multiplayer.multiplayer_peer = peer
	
	peer.peer_connected.connect(on_server_peer_connected)
	peer.peer_disconnected.connect(on_server_peer_disconnected)
	
	print("hosting")

func create_client(web_socket_url: String) -> void:
	var peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
	peer.create_client(web_socket_url)
	multiplayer.multiplayer_peer = peer
	
	print("connecting")

func disconnect_peer() -> void:
	print("{0}: disconnecting".format([multiplayer.multiplayer_peer.get_unique_id()]))
	multiplayer.multiplayer_peer = null

# connection signals
func on_server_peer_connected(id: int) -> void:
	print("{0}: connected".format([id]))

func on_server_peer_disconnected(id: int) -> void:
	print("{0}: disconnected".format([id]))
#endregion



var players_queuing: Array[int] = []

# request server to queue
# adding player to queue
@rpc("any_peer", "reliable")
func queue_for_game(id: int) -> void:
	
	players_queuing.append(id)
	print("{0}: queued".format([id]))
	
	match_making()

# match making
# might, but probably wont, actually add match_making
func match_making() -> void:
	if players_queuing.size() >= 2:
		var player_1_is_white: bool = (randi() % 2 == 0)
		
		create_match(players_queuing[0], players_queuing[1], player_1_is_white)
		players_queuing.remove_at(0)
		players_queuing.remove_at(0)



# creates a match
# establishes a connection through a unique match id and creates the game serverside
var matches: Dictionary[int, Dictionary] = {}
var game_scene: PackedScene = preload("res://chess_game/chess_game.tscn")
func create_match(player_1_id: int, player_2_id: int, player_1_is_white: bool) -> void:
	var match_id: int = get_unique_match_id()
	
	var game = game_scene.instantiate()
	add_child(game)
	
	if player_1_is_white:
		matches[match_id] = {
			"player_white_id" : player_1_id,
			"player_black_id" : player_2_id,
			"game" : game
		}
	else:
		matches[match_id] = {
			"player_white_id" : player_2_id,
			"player_black_id" : player_1_id,
			"game" : game
		}
	
	start_match.rpc_id(matches[match_id]["player_white_id"], match_id, true)
	start_match.rpc_id(matches[match_id]["player_black_id"], match_id, false)

# returns a unique match id
# returns the iterators value then changes the value
var match_id_iterator: int = 0
func get_unique_match_id() -> int:
	var match_id = match_id_iterator
	match_id_iterator += 1
	return match_id




var is_in_match: bool = false
var current_match_id: int = 0
var team_is_white: bool = true
# server telling client to start a game and which match they are in
# setup match and store match_id
@rpc("authority","reliable")
func start_match(match_id: int, _team_is_white: bool) -> void:
	print("{0}: started match {1}".format([multiplayer.multiplayer_peer.get_unique_id(), match_id]))
	
	is_in_match = true
	current_match_id = match_id
	team_is_white = _team_is_white
	
	get_tree().change_scene_to_packed(game_scene)

signal server_sent_valid_input()
# server receives input from client
# checking if the move is valid then telling clients to do the move
@rpc("any_peer","reliable")
func input(player_id: int, match_id: int, move_dict: Dictionary) -> void:
	
	var current_match = matches[match_id]
	var move: Move = Move.deserialize(move_dict)
	
	var player_team_is_white: bool = (current_match["player_white_id"] == player_id)
	
	var valid_move: bool = current_match["game"].is_move_valid(move, player_team_is_white)
	if valid_move:
		
		var player_white_id: int = current_match["player_white_id"]
		var player_black_id: int = current_match["player_black_id"]
		
		receive_valid_input.rpc_id(player_white_id, move_dict)
		receive_valid_input.rpc_id(player_black_id, move_dict)
		server_sent_valid_input.emit()

# called by server to clients
# a serialized move object given to all clients upon approved input move
signal on_networking_received_valid_input(move: Move)
@rpc("authority", "reliable")
func receive_valid_input(move_dict: Dictionary) -> void:
	
	var move: Move = Move.deserialize(move_dict)
	on_networking_received_valid_input.emit(move)


# finds the player who is responsible for choosing the promotion type then requesting a type
# sends them
func promotion(match_id: int, _team_is_white: bool, position: Vector2i) -> void:
	var current_match = matches[match_id]
	
	await server_sent_valid_input
	if _team_is_white:
		var player_white_id: int = current_match["player_white_id"]
		request_promotion_type.rpc_id(player_white_id, position)
	else:
		var player_black_id: int = current_match["player_black_id"]
		request_promotion_type.rpc_id(player_black_id, position)


signal network_request_promotion_type(position: Vector2i)
# called on a player upon a promotion in multiplayer mode
# the player will use the position to locate the piece which they will then prompt for a promotion
@rpc("authority", "reliable")
func request_promotion_type(position: Vector2i) -> void:
	network_request_promotion_type.emit(position)

# called on the server by a player who had been requested a promotion type
# receives an int represeting the type through Globals.TYPE
@rpc("any_peer", "reliable")
func send_promotion_type(match_id: int, chosen_type: int, position: Vector2i) -> void:
	
	var current_match = matches[match_id]
	
	var player_white_id: int = current_match["player_white_id"]
	var player_black_id: int = current_match["player_black_id"]
	
	send_promotion.rpc_id(player_white_id, chosen_type, position)
	send_promotion.rpc_id(player_black_id, chosen_type, position)


var display_name: String = "Anonymous"


signal on_receive_promotion(type: Globals.TYPE, position: Vector2i)
# called on the players so that they update the type of the promoted piece
# ferry a signal to the chess game node to ferry another signal
@rpc("authority", "reliable")
func send_promotion(chosen_type: int, position: Vector2i) -> void:
	var type: Globals.TYPE = chosen_type as Globals.TYPE
	on_receive_promotion.emit(type, position)

# gives the server the chat message so it can tell all clients about it
# calls rpc in all clients associated with match
@rpc("any_peer","reliable")
func send_chat_to_server(match_id: int, chat: String, _display_name) -> void:
	var current_match = matches[match_id]
	
	var player_white_id: int = current_match["player_white_id"]
	var player_black_id: int = current_match["player_black_id"]
	
	receive_chat_from_server.rpc_id(player_white_id, chat, _display_name)
	receive_chat_from_server.rpc_id(player_black_id, chat, _display_name)

signal on_network_chat_received(chat: String)
# sends chat message from server to client
# clients emit signal received by chat window
@rpc("authority", "reliable")
func receive_chat_from_server(chat: String, _display_name: String) -> void:
	on_network_chat_received.emit(chat, _display_name)
