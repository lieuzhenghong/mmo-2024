extends Node

# This will contain player info for every player,
# with the keys being each player's unique IDs.
var players = {}
var players_loaded = 0
var chatlog = PackedStringArray(["Hello World"])


signal chatlog_updated
