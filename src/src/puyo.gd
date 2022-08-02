extends Object
class_name Puyo

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const textures = {
	0: null,
	1: preload("res://Assets/Puyo/1.png"),
	2: preload("res://Assets/Puyo/2.png"),
	3: preload("res://Assets/Puyo/3.png"),
	4: preload("res://Assets/Puyo/4.png")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

static func get_texture_from_value(val: int):
	return textures[val]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
