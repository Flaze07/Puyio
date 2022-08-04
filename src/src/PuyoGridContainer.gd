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

var gravity_cooldown = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_puyo()
	pass # Replace with function body.

func draw_board():
	puyo_board.set_value_vec2(dynamic_puyo.position1, dynamic_puyo.value1)
	puyo_board.set_value_vec2(dynamic_puyo.position2, dynamic_puyo.value2)
	for child in get_children():
		child.queue_free()
	for row in range(12):
		for col in range(6):
			var tex_rect = TextureRect.new()
			tex_rect.rect_min_size = Vector2(16, 16)
			tex_rect.texture = Puyo.get_texture_from_value(puyo_board.get_value(col, row))
			add_child(tex_rect)

func spawn_puyo():
	dynamic_puyo.position1 = Vector2(2, 0)
	dynamic_puyo.value1 = 1 + randi() % 4
	dynamic_puyo.position2 = Vector2(2, -1)
	dynamic_puyo.value2 = 1 + randi() % 4

func clear_dynamic_puyo():
	puyo_board.set_value_vec2(dynamic_puyo.position1, 0)
	puyo_board.set_value_vec2(dynamic_puyo.position2, 0)

func move_puyo(delta):
	if gravity_cooldown > 0:
		gravity_cooldown -= delta
		return
	
	if can_go_down():
		clear_dynamic_puyo()
		
		dynamic_puyo.position1.y += 1
		dynamic_puyo.position2.y += 1
	
	gravity_cooldown += GameConfig.gravity
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_puyo(delta)
	draw_board()
	pass

#extra functions
func can_go_down():
	#checks the first puyo
	var down = dynamic_puyo.position1
	down.y += 1
	if down != dynamic_puyo.position2:
		if puyo_board.get_value_vec2(down) != 0 or down.y >= puyo_board.row:
			return false
	
	down = dynamic_puyo.position2
	down.y += 1
	if down != dynamic_puyo.position1:
		if puyo_board.get_value_vec2(down) != 0 or down.y >= puyo_board.row:
			return false
		
	return true
	
func try_move_left():
	var puyo_pos: Vector2
	if dynamic_puyo.position1.x < dynamic_puyo.position2.x:
		puyo_pos = dynamic_puyo.position1
	else:
		puyo_pos = dynamic_puyo.position2
	
	puyo_pos.x -= 1
	
	if puyo_board.get_value_vec2(puyo_pos) != 0 or puyo_board.get_value_vec2(puyo_pos) == null:
		return
	
	dynamic_puyo.position1.x -= 1
	dynamic_puyo.position2.x -= 1

func try_move_right():
	var puyo_pos: Vector2
	if dynamic_puyo.position1.x > dynamic_puyo.position2.x:
		puyo_pos = dynamic_puyo.position1
	else:
		puyo_pos = dynamic_puyo.position2
	
	puyo_pos.x += 1
	
	if puyo_board.get_value_vec2(puyo_pos) != 0 or puyo_board.get_value_vec2(puyo_pos) == null:
		return
	
	dynamic_puyo.position1.x += 1
	dynamic_puyo.position2.x += 1
	
func try_soft_drop():
	if not can_go_down():
		return
	
	dynamic_puyo.position1.y += 1
	dynamic_puyo.position2.y += 1

func try_hard_drop():
	#handle if both are on different column
	if dynamic_puyo.position1.x != dynamic_puyo.position2.x:
		var check_pos1 = dynamic_puyo.position1
		
		check_pos1.y += 1
		while puyo_board.get_value_vec2(check_pos1) == 0 \
				and puyo_board.get_value_vec2(check_pos1) != null:
			check_pos1.y += 1
			
		var check_pos2 = dynamic_puyo.position2.y
		
		check_pos2.y ++ 1
		while puyo_board.get_value_vec2(check_pos2) == 0 \
				and puyo_board.get_value_vec2(check_pos2) != null:
			check_pos2.y += 1
		
		dynamic_puyo.position1.y = check_pos1.y - 1
		dynamic_puyo.position2.y = check_pos2.y - 1
		
	#handle if they're on the same column
	else:
		var check_pos: Vector2
		if dynamic_puyo.position1.y < dynamic_puyo.position2.y:
			check_pos = dynamic_puyo.position2
		else:
			check_pos = dynamic_puyo.position1
		
		check_pos.y += 1
		print(puyo_board.get_value_vec2(check_pos))
		while (puyo_board.get_value_vec2(check_pos) == 0 
				and puyo_board.get_value_vec2(check_pos) != null):
			check_pos.y += 1
		
		if dynamic_puyo.position1.y < dynamic_puyo.position2.y:
			dynamic_puyo.position2.y = check_pos.y - 1
			dynamic_puyo.position1.y = check_pos.y - 2
		else:
			dynamic_puyo.position1.y = check_pos.y - 1
			dynamic_puyo.position2.y = check_pos.y - 2

func try_rot_cw():
	#if they're in the same column
	if dynamic_puyo.position1.x == dynamic_puyo.position2.x:
		var check_right = puyo_board.get_value(dynamic_puyo.position1.x+1, dynamic_puyo.position1.y)
		var check_left = puyo_board.get_value(dynamic_puyo.position1.x-1, dynamic_puyo.position1.y)
		if dynamic_puyo.position1.y > dynamic_puyo.position2.y:
			if check_right != 0 and check_right == null:
				if check_left != 0 and check_left == null:
					return
				dynamic_puyo.position1.x -= 1
				dynamic_puyo.position2.x -= 1
			
			dynamic_puyo.position2.x += 1
			dynamic_puyo.position2.y += 1
		else:
			if check_left != 0 and check_left == null:
				if check_right != 0 and check_right == null:
					return
				dynamic_puyo.position1.x += 1
				dynamic_puyo.position2.x += 1
				
			dynamic_puyo.position2.x -= 1
			dynamic_puyo.position2.y -= 1
	#if they're not in the same column
	else:
		if dynamic_puyo.position1.x > dynamic_puyo.position2.x:
			dynamic_puyo.position2.y -= 1
			dynamic_puyo.position2.x += 1
		else:
			var check = puyo_board.get_value(dynamic_puyo.position1.x, dynamic_puyo.position1.y+1)
			if check != 0 and check == null:
				dynamic_puyo.position1.y -= 1
				dynamic_puyo.position2.y -= 1
				
			dynamic_puyo.position2.y += 1
			dynamic_puyo.position2.x -= 1
	
func try_rot_ccw():
	#if they're in the same column
	if dynamic_puyo.position1.x == dynamic_puyo.position2.x:
		var check_right = puyo_board.get_value(dynamic_puyo.position1.x+1, dynamic_puyo.position1.y)
		var check_left = puyo_board.get_value(dynamic_puyo.position1.x-1, dynamic_puyo.position1.y)
		
		if dynamic_puyo.position1.y > dynamic_puyo.position2.y:
			if check_left != 0 and check_left == null:
				if check_right != 0 and check_right == null:
					return
				dynamic_puyo.position1.x += 1
				dynamic_puyo.position2.x += 1
				
			dynamic_puyo.position2.x -= 1
			dynamic_puyo.position2.y += 1
		else:
			dynamic_puyo.position2.x += 1
			dynamic_puyo.position2.y -= 1
	#if they're not in the same column
	else:
		if dynamic_puyo.position1.x > dynamic_puyo.position2.x:
			var check = puyo_board.get_value(dynamic_puyo.position1.x, dynamic_puyo.position1.y+1)
			if check != 0 and check == null:
				dynamic_puyo.position1.y -= 1
				dynamic_puyo.position2.y -= 1
				
			dynamic_puyo.position2.y += 1
			dynamic_puyo.position2.x += 1
		else:
			dynamic_puyo.position2.y -= 1
			dynamic_puyo.position2.x -= 1

func try_rot_180():
	var temp = dynamic_puyo.position1
	dynamic_puyo.position1 = dynamic_puyo.position2
	dynamic_puyo.position2 = temp

func process_input(event):
	clear_dynamic_puyo()
	match event:
		"move_left":
			try_move_left()
		"move_right":
			try_move_right()
		"soft_drop":
			try_soft_drop()
		"hard_drop":
			try_hard_drop()
		"rot_cw":
			try_rot_cw()
		"rot_ccw":
			try_rot_ccw()
		"rot_180":
			try_rot_180()
