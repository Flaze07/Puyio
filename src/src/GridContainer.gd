extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var puyo_board = PuyoBoard.new()
var is_player = true

class DynamicPuyo:
	var position1: Vector2
	var value1: int
	var position2: Vector2	
	var value2: int

var dynamic_puyo = DynamicPuyo.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

func draw_board():
	for child in get_children():
		child.queue_free()
	for row in range(12):
		for col in range(6):
			var tex_rect = TextureRect.new()
			tex_rect.rect_min_size = Vector2(16, 16)
			tex_rect.texture = Puyo.get_texture_from_value(puyo_board.get_value(col, row))
			add_child(tex_rect)

func spawn_puyo():
	dynamic_puyo.position1 = Vector2(3, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	draw_board()
	pass
