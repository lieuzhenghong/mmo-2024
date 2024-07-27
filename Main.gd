extends Node
# signal player_connected(peer_id, player_info)
# signal player_disconnected(peer_id)
# signal server_disconnected
signal chatlog_updated

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}

var chatlog = PackedStringArray(["Hello World"])

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

var players_loaded = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	chatlog_updated.connect(_on_chatlog_update)
	if OS.has_feature("server") or OS.has_feature("editor"):
		# Create a new global lobby
		setup_server()
	else:
		setup_client()

const PORT = 6969
const MAX_CLIENTS = 4
const IP_ADDRESS = "192.168.18.30"

func setup_server():
	print("Setting up a server")
	# Create server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	
func setup_client():
	print("I am a client")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

# When a peer connects, send them my player info.
# This allows transfer of all desired data for each player, not only the unique ID.
func _on_player_connected(id):
	print("New player connected!")
	chatlog.push_back("New player connected.")
	player_info.name = "Client_" + str(multiplayer.get_unique_id())
	_register_player.rpc_id(id, player_info) # call_rpc_with_id(_register_player, id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	print("Updating player info")
	var new_player_id = multiplayer.get_remote_sender_id()

	players[new_player_id] = new_player_info
	print(new_player_id, new_player_info)
	
	chatlog.push_back("Player ID: {id}".format({"id": new_player_id}))
	chatlog_updated.emit()
	
	# player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	print("Player ID {id} disconnected".format({"id": id}))
	chatlog.push_back("Player {id} disconnected".format({"id": id}))
	chatlog_updated.emit()
	players.erase(id)
	print(players)
	# player_disconnected.emit(id)

# When the chatlog updates, update the chatlog on all peers
func _on_chatlog_update():
	_update_chatlog.rpc(chatlog)

@rpc("authority", "unreliable")
func _update_chatlog(new_chatlog):
	chatlog = new_chatlog

# This runs on the client only.
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	# player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	# server_disconnected.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Control/ChatLog.text = ""
	$Control/ChatLog.text = '\n'.join(chatlog)
