extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.has_feature("server") or OS.has_feature("editor"):
		# Create a new global lobby
		setup_server()
	else:
		setup_client()

func setup_server():
	print("Setting up a server")
	# host_game()
	
func setup_client():
	print("I am a client")
	# join_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
