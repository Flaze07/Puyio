extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var puyo_board = PuyoBoard.new()
var is_player = true
var lockdown_time = 0

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
	
func neighbour(x,y):
	var neigh = [
		Vector2(x-1, y),
		Vector2(x+1, y),
		Vector2(x, y+1),
		Vector2(x, y-1)
	]
	var res = []
	for e in neigh:
		if not puyo_board.is_valid_or_empty_vec2(e):
			res.append(e)

	return res
	
func find_matching_puyo(x, y):
	var color = puyo_board.get_value(x, y)
	var counter = 0
	var q = []
	var temp = []
	var visited = []
	temp.append(Vector2(x, y))
	q.append(Vector2(x,y))
	while len(q) > 0:
		var posi = q.pop_at(0)
		var neigh = neighbour(posi[0], posi[1])
		for e in neigh:
			if not(e in visited):
				if puyo_board.get_value_vec2(e) == color:
					counter += 1
					visited.append(e)
					temp.append(e)
					q.append(e)
	if counter >= 4:
		for e in temp:
			puyo_board.set_value_vec2(e, 0)

func update_puyo_position():
	var puyo_y = puyo_board.row-1
	var updated_puyo: Array = []
	while puyo_y >= 0:
		for puyo_x in range(puyo_board.col):
			var puyo_col = puyo_board.get_value(puyo_x, puyo_y)
			if puyo_col != 0:
				var new_y = puyo_y + 1
				while puyo_board.is_valid_or_empty(puyo_x, new_y):
					new_y +=1 
					
				new_y -= 1
				if new_y == puyo_y:
					continue
				updated_puyo.append(Vector2(puyo_x, new_y))
				puyo_board.set_value(puyo_x, puyo_y, 0)
				puyo_board.set_value(puyo_x, new_y, puyo_col)
		puyo_y -= 1
		
	return updated_puyo

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
	dynamic_puyo = DynamicPuyo.new()
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
		lockdown_time = 0
	else:
		lockdown_time += delta
		if lockdown_time >= GameConfig.lockdown_time_set:
			clear_dynamic_puyo()
			try_hard_drop()
			draw_board()
			find_matching_puyo(dynamic_puyo.position1.x, dynamic_puyo.position1.y)
			find_matching_puyo(dynamic_puyo.position2.x, dynamic_puyo.position2.y)
			
			update_puyo_position()
			
			spawn_puyo()
			
			lockdown_time = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_player:
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
	
	if not puyo_board.is_valid_or_empty_vec2(puyo_pos):
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
	
	if not puyo_board.is_valid_or_empty_vec2(puyo_pos):
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
		while puyo_board.is_valid_or_empty_vec2(check_pos1):
			check_pos1.y += 1
			
		var check_pos2 = dynamic_puyo.position2
		
		check_pos2.y += 1
		while puyo_board.is_valid_or_empty_vec2(check_pos2):
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
		while puyo_board.is_valid_or_empty_vec2(check_pos):
			check_pos.y += 1
		
		if dynamic_puyo.position1.y < dynamic_puyo.position2.y:
			dynamic_puyo.position2.y = check_pos.y - 1
			dynamic_puyo.position1.y = check_pos.y - 2
		else:
			dynamic_puyo.position1.y = check_pos.y - 1
			dynamic_puyo.position2.y = check_pos.y - 2
	lockdown_time = GameConfig.lockdown_time_set

func try_rot_cw():
	clear_dynamic_puyo()
	#if they're in the same column
	if dynamic_puyo.position1.x == dynamic_puyo.position2.x:
		#if anchor is below
		if dynamic_puyo.position1.y > dynamic_puyo.position2.y:
			for e in GameConfig.PRS["rot_cw"]["below"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x += 1
				puyo2.y += 1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
		#if anchor is above
		else:
			for e in GameConfig.PRS["rot_cw"]["above"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x -= 1
				puyo2.y -= 1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
	#if they're not in the same column
	else:
		#if anchor is to the right
		if dynamic_puyo.position1.x > dynamic_puyo.position2.x:
			for e in GameConfig.PRS["rot_cw"]["right"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x += 1
				puyo2.y -= 1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
		#if anchor is to the left
		else:
			var check = puyo_board.get_value(dynamic_puyo.position1.x, dynamic_puyo.position1.y+1)
			for e in GameConfig.PRS["rot_cw"]["left"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x -= 1
				puyo2.y +=1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
	return false
	
func try_rot_ccw():
	clear_dynamic_puyo()
	#if they're in the same column
	if dynamic_puyo.position1.x == dynamic_puyo.position2.x:
		#if anchor is below
		if dynamic_puyo.position1.y > dynamic_puyo.position2.y:
			for e in GameConfig.PRS["rot_ccw"]["below"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x -= 1
				puyo2.y += 1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
		#if anchor is above
		else:
			for e in GameConfig.PRS["rot_ccw"]["above"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x += 1
				puyo2.y -= 1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
	#if they're not in the same column
	else:
		#if anchor is to the right
		if dynamic_puyo.position1.x > dynamic_puyo.position2.x:
			for e in GameConfig.PRS["rot_ccw"]["right"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x += 1
				puyo2.y += 1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
		#if anchor is to the left
		else:
			var check = puyo_board.get_value(dynamic_puyo.position1.x, dynamic_puyo.position1.y+1)
			for e in GameConfig.PRS["rot_ccw"]["left"]:
				var puyo1 = dynamic_puyo.position1
				var puyo2 = dynamic_puyo.position2
				
				puyo2.x -= 1
				puyo2.y -=1
				
				puyo1 += e
				puyo2 += e
				
				if (puyo_board.is_valid_or_empty_vec2(puyo1) 
						and puyo_board.is_valid_or_empty_vec2(puyo2)):
					dynamic_puyo.position1 = puyo1
					dynamic_puyo.position2 = puyo2
					return true
	return false

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
			if try_rot_cw():
				lockdown_time = 0
				gravity_cooldown = GameConfig.gravity
		"rot_ccw":
			try_rot_ccw()
		"rot_180":
			try_rot_180()
