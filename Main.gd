extends Node
# signal player_connected(peer_id, player_info)
# signal player_disconnected(peer_id)
# signal server_disconnected

var SERVER_FLAG = true

# This is the local player info. This should be modified locally
# before the connection is made. It will be passed to every other peer.
# For example, the value of "name" can be set to something the player
# entered in a UI scene.
var player_info = {"name": "Name"}

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	Globals.chatlog_updated.connect(Globals._on_chatlog_update)
	if SERVER_FLAG:
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
	Globals.change_chatlog("New player connected.")
	player_info.name = "Client_" + str(multiplayer.get_unique_id())
	_register_player.rpc_id(id, player_info) # call_rpc_with_id(_register_player, id, player_info)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	print("Updating player info")
	var new_player_id = multiplayer.get_remote_sender_id()

	Globals.players[new_player_id] = new_player_info
	print(new_player_id, new_player_info)
	
	Globals.change_chatlog("Player ID: {id}".format({"id": new_player_id}))
	# player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	print("Player ID {id} disconnected".format({"id": id}))
	Globals.change_chatlog("New player connected.")
	Globals.players.erase(id)
	# player_disconnected.emit(id)

# This runs on the client only.
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	Globals.players[peer_id] = player_info
	# player_connected.emit(peer_id, player_info)

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	Globals.players.clear()
	# server_disconnected.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
