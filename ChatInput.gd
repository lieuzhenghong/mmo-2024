extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	var text = get_node("TextEdit").get_text()
	Globals.change_chatlog(text)
	get_node("TextEdit").clear()
