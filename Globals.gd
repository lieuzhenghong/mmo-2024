extends Node

var SERVER_FLAG = true
# Gamestate
var gamestate = {}

func _update_gamestate(player_id, point):
	gamestate[player_id] = point

# TODO temporary function. In reality, players shouldn't be able to update the
# gamestate like this: they should send inputs to the server and the server
# will update the position.
@rpc("any_peer", "unreliable")
func _request_update_gamestate(point):
	var player_id = multiplayer.get_remote_sender_id()
	gamestate[player_id] = point

var tick_rate = 0.1  # 100ms in seconds
var time_since_last_tick = 0

func _process(delta):
	time_since_last_tick += delta
	if time_since_last_tick >= tick_rate:
		_on_tick()
		time_since_last_tick -= tick_rate

func _on_tick():
	# This function will be called every 100ms
	print(gamestate)
	if SERVER_FLAG:
		_propagate_gamestate.rpc(gamestate)

@rpc("authority", "unreliable")
func _propagate_gamestate(servers_gamestate):
	gamestate = servers_gamestate
	print(gamestate)

# Input Buffer global variable
var input_buffer = {}

# Chatlog global variable
var chatlog = PackedStringArray(["Hello World"])

signal chatlog_updated

func change_chatlog(new_string):
	chatlog.push_back(new_string)
	chatlog_updated.emit()

# When the chatlog updates, update the chatlog on all peers
func _on_chatlog_update():
	_propagate_chatlog.rpc(chatlog)

# Change "call_local" to "call_remote" if you don't want server to send message
@rpc("any_peer", "call_local", "unreliable")
func _request_update_chatlog(text):
	# Server should check here. This is an example check
	var sender_id = multiplayer.get_remote_sender_id()
	if (text != "Donald"):
		change_chatlog(str(sender_id) + ": " + text)
	else:
		change_chatlog(str(sender_id) + ": " + "GAYLORD") 
	
@rpc("authority", "unreliable")
func _propagate_chatlog(new_chatlog):
	chatlog = new_chatlog
	

