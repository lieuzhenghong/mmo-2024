extends Node2D
var player
# Called when the node enters the scene tree for the first time.
func _ready():
	player = preload("res://Player.tscn").instantiate()
	add_child(player)
	player.position = Vector2(100, 100)  # Starting position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	# Check if the input event is a mouse button press
	if event is InputEventMouseButton and event.pressed:
		# Update the target position to the mouse click position
		player.position = event.position
