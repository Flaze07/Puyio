extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gravity = 0.3
var random_seed = 0
var lockdown_time_set = 0.5

#PRS stands for Puyo Rotation System
const PRS = {
	"rot_cw": {
		#Anchor is below
		"below": [
			Vector2(0, 0),
			Vector2(-1, 0),
			Vector2(0, -1),
			Vector2(-1, -1)
		],
		#Anchor is above
		"above": [
			Vector2(0, 0),
			Vector2(1, 0)
		],
		#Anchor is to the left
		"left": [
			Vector2(0, 0),
			Vector2(0, -1)
		],
		#Anchor is to the right
		"right": [
			Vector2(0, 0)
		]
	},
	"rot_ccw": {
		#Anchor is below
		"below": [
			Vector2(0, 0),
			Vector2(1, 0),
			Vector2(0, -1),
			Vector2(1, -1)
		],
		"above": [
			Vector2(0, 0),
			Vector2(-1, 0)
		],
		"left": [
			Vector2(0, 0)
		],
		"right": [
			Vector2(0, 0),
			Vector2(0, -1)
		]
	}
}

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	pass # Replace with function body.

func set_seed(new_val):
	seed(new_val)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
