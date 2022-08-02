extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player_board: GridContainer

func init_player_board():
	var parent_node = get_parent()
	for node in parent_node.get_children():
		if node.get_child_count() > 0:
			for node2 in node.get_children():
				if node2 is GridContainer:
					if node2.is_player:
						player_board = node2
						return

# Called when the node enters the scene tree for the first time.
func _ready():
	init_player_board()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if event.is_action_pressed("move_left"):
		player_board.try_move_left()
	if event.is_action_pressed("move_right"):
		player_board.try_move_right()
	pass
