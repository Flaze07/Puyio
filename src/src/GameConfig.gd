extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity = 0.3
var random_seed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.

func set_seed(new_val):
	random_seed = new_val

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
