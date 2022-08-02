extends Object

class_name PuyoBoard

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var col = 6
var row = 12
var board: Array

func _init():
	board = []
	board.resize(col * row)
	for i in range(row*col):
		board[i] = 0
	pass

func get_value(x, y):
	if x < 0 or x >= col:
		return null
	if y < 0 or y >= row:
		return null
	return board[x + (y * col)]

func get_value_vec2(coord: Vector2):
	return get_value(coord.x, coord.y)
	
func set_value(x, y, val) -> bool:
	if x < 0 or x >= col:
		return false
	if y < 0 or y >= row:
		return false
	if val < 0 and val > 4:
		return false
	board[x + (y * col)] = val
	return true

func set_value_vec2(coord: Vector2, val) -> bool:
	return set_value(coord.x, coord.y, val)

# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
