extends Node

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}
var players_loaded = 0

# Chatlog global variable (in future, gamestate)
var chatlog = PackedStringArray(["Hello World"])

signal chatlog_updated

func change_chatlog(new_string):
	chatlog.push_back(new_string)
	chatlog_updated.emit()

# When the chatlog updates, update the chatlog on all peers
func _on_chatlog_update():
	_update_chatlog.rpc(chatlog)

@rpc("any_peer", "call_local", "unreliable")
func _update_chatlog_request(text):
	# Server should check here. This is an example check
	var sender_id = multiplayer.get_remote_sender_id()
	if (text != "Donald"):
		change_chatlog(str(sender_id) + ": " + text)
	else:
		change_chatlog(str(sender_id) + ": " + "GAYLORD") 
	
@rpc("authority", "unreliable")
func _update_chatlog(new_chatlog):
	chatlog = new_chatlog
