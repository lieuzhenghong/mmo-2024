extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	Globals.chatlog_updated.connect(Globals._on_chatlog_update)
	if Globals.SERVER_FLAG:
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
	_register_player.rpc_id(id) # call_rpc_with_id(_register_player, id, player_info)

@rpc("any_peer", "reliable")
func _register_player():
	var new_player_id = multiplayer.get_remote_sender_id()
	Globals.change_chatlog("Player ID: {id}".format({"id": new_player_id}))
	Globals._update_gamestate(new_player_id, Vector2(0, 0))

func _on_player_disconnected(id):
	Globals.change_chatlog("Player ID {id} disconnected".format({"id": id}))
	Globals.gamestate.erase(id)

# This runs on the client only.
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()

func _on_connected_fail():
	multiplayer.multiplayer_peer = null

func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	# server_disconnected.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
