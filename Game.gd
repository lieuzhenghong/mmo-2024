extends Node2D

# Dictionary of int (id) -> Player
# We will populate this from gamestate.
var players = {}
var player = preload("res://Player.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	for id in Globals.gamestate.keys():
		player.instantiate()
		add_child(player)
		player.position = Globals.gamestate[id]
		players[id] = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	for id in Globals.gamestate.keys():
		players[id] = player.instantiate()
		add_child(player)
		
	for id in players.keys():
		var player = players[id]
		player.position = Globals.gamestate[id]
	
func _input(event):
	# Check if the input event is a mouse button press
	if event is InputEventMouseButton and event.pressed:
		# Update the target position to the mouse click position
		 # player.position = event.position
		pass
