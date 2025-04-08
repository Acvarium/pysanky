extends Node2D

const PIECE_IMAGE_SIZE = 400.0

const LEFT_OFFSET = 40.0
export (int) var width
export (int) var height
onready var main_node = get_tree().get_root().get_node("Main")

var x_start = 1.0
var y_start = 1.0
var offset = 40.0
var piece_scale = 1.0

var number_of_pieces = 5

var piece_loaded = preload("res://pieces/green_piece.tscn")

var all_pieces = []

var first_touch_on_grid = Vector2()
var final_touch_on_grid = Vector2()
var controlling = false
var locked = false

var sprites = [
	preload("res://sprites/p/01.png"),
	preload("res://sprites/p/02.png"),
	preload("res://sprites/p/03.png"),
	preload("res://sprites/p/04.png"),
	preload("res://sprites/p/05.png"),
#	preload("res://sprites/p2/06.png")
]

var swap_list = []


func generate_swap_list():
	var check_list = {}  # Використовуємо словник для швидких перевірок

	# Горизонтальні обміни
	for i in range(width - 1):
		for j in range(height):
			var a = grid_to_line(i, j)
			var b = grid_to_line(i + 1, j)
			var swap_key = swap_addr(a, b)

			if not swap_key in check_list:
				swap_list.append([i, j, i + 1, j])
				check_list[swap_key] = true

	# Вертикальні обміни
	for i in range(width):
		for j in range(height - 1):
			var a = grid_to_line(i, j)
			var c = grid_to_line(i, j + 1)
			var swap_key = swap_addr(a, c)

			if not swap_key in check_list:
				swap_list.append([i, j, i, j + 1])
				check_list[swap_key] = true


func _ready():
	generate_swap_list()
#	if height == 6 and width == 5:
#		main_node.set_background_texture(lotok5x6_loaded)
	var screen_size = get_viewport().get_visible_rect().size
	offset = (screen_size.x - LEFT_OFFSET * 2) / width
	piece_scale = offset / PIECE_IMAGE_SIZE
	
	x_start = offset / 2 + LEFT_OFFSET
	y_start = screen_size.y - offset / 2 - (screen_size.y - \
		(offset * height)) / 2
	randomize()
	all_pieces = make_2d_array()
	spawn_pieces()
	main_node.show_number_of_good_moves(check_moves())


func make_2d_array():
	var array = []
	for i in width:
		array.append([])
		for j in height:
			array[i].append(null)
	return array


func spawn_pieces():
	for i in range(width):
		for j in range(height):
			random_piece(i, j)


func all_pieces_to_data():
	var pieces_IDs = []
	for i in range(width):
		var row_data = []
		for j in range(height):
			if all_pieces[i][j] != null:
				row_data.append(all_pieces[i][j].color_index)
			else:
				row_data.append(-1)
		pieces_IDs.append(row_data)
	return pieces_IDs


func swap_pieces_in_data(data, x1, y1, x2, y2):
	var p = data[x1][y1]
	data[x1][y1] = data[x2][y2]
	data[x2][y2] = p
	return data
	

func swap_addr(a, b):
	if a > b:
		return [b, a]
	return [a, b]


func grid_to_line(x, y):
	return x * height + y


func check_moves():
	var ss = ""
	var ss2 = ""
	
	var pieces_IDs = all_pieces_to_data()
	var good_moves_count = 0
	var good_moves = []
	for s in swap_list:
		var x1 = s[0]
		var y1 = s[1]
		var x2 = s[2]
		var y2 = s[3]
		
		var swapped_data = swap_pieces_in_data(
			pieces_IDs.duplicate(true), x1, y1, x2, y2)

		if find_matches_from_data(swapped_data) != null:
			good_moves_count += 1
			var debug_line = str(x1) + str(y1) + " <> " + str(x2) + str(y2) + "\n"
			if (good_moves_count < 6):
				ss += debug_line
			else:
				ss2 += debug_line
	$Moves.text = ss
	$Moves2.text = ss2

	return good_moves_count
			

func random_piece(i, j):
	var rand = randi() % number_of_pieces
	var loops = 100
	while(match_at(i, j, rand) and loops > 0):
		rand = randi() % number_of_pieces
		loops -= 1
	var piece = piece_loaded.instance()
	add_child(piece)
	piece.position = grid_to_pixel(i, j)
	piece.color_index = rand
	piece.get_node("Sprite").texture = sprites[rand]
	piece.get_node("Sprite").scale = Vector2(piece_scale, piece_scale)
	piece.get_node("Halo").scale = Vector2(piece_scale, piece_scale)
	piece.get_node("Shadow").scale = Vector2(piece_scale, piece_scale) * 1.15
	piece.get_node("Sprite").rotation = randf() * PI * 0.5
	piece.highlite(false)
	all_pieces[i][j] = piece


func match_at(i, j, color_index):
	if i > 1:
		if all_pieces[i-1][j] != null and all_pieces[i-2][j] != null:
			if all_pieces[i-1][j].color_index == color_index and \
			all_pieces[i-2][j].color_index == color_index:
				return true
	if j > 1:
		if all_pieces[i][j-1] != null and all_pieces[i][j-2] != null:
			if all_pieces[i][j-1].color_index == color_index and \
			all_pieces[i][j-2].color_index == color_index:
				return true
	return false


func grid_to_pixel(col, row):
	var new_x = x_start + offset * col
	var new_y = y_start + -offset * row
	return Vector2(new_x, new_y)


func pixel_to_grid(pixel_pos):
	var new_col = round((pixel_pos.x - x_start) / offset)
	var new_row = round((pixel_pos.y - y_start) / -offset)
	return Vector2(new_col, new_row)


func is_in_grid(grid_pos):
	return grid_pos.x >= 0 and grid_pos.x < width and \
		grid_pos.y >= 0 and grid_pos.y < height


func _input(event):
	if Global.show_help_screen:
		return
	if locked:
		return
	if event is InputEventScreenTouch and event.index == 0:
		if event.is_pressed():
			var first_touch = event.position
			first_touch_on_grid = pixel_to_grid(first_touch)
			if is_in_grid(first_touch_on_grid):
				controlling = true
				all_pieces[first_touch_on_grid.x][first_touch_on_grid.y].highlite(true)
		else:
			if !controlling:
				return
			reset_piece_color(first_touch_on_grid)
			var final_touch = event.position
			final_touch_on_grid = pixel_to_grid(final_touch)
			if is_in_grid(final_touch_on_grid):
				if is_swap_allowed(first_touch_on_grid, final_touch_on_grid):
					swap_pieces(first_touch_on_grid, final_touch_on_grid)
					if !find_matches():
						$SwapBackTimer.start()
						locked = true
			controlling = false


func is_swap_allowed(grid_pos1, grid_pos2):
	var h_dist = abs(grid_pos1.x - grid_pos2.x)
	var v_dist = abs(grid_pos1.y - grid_pos2.y)
	if h_dist == 1 and v_dist == 0:
		return true
	if v_dist == 1 and h_dist == 0:
		return true
	return false


func reset_piece_color(grid_pos):
	if !is_valide_piece(grid_pos):
		return
	var _piece = all_pieces[grid_pos.x][grid_pos.y]
	_piece.highlite(false)


func is_valide_piece(grid_pos):
	if grid_pos.x < 0 or grid_pos.x >= width:
		return false
	if grid_pos.y < 0 or grid_pos.y >= height:
		return false
	if all_pieces[grid_pos.x][grid_pos.y] == null:
		return false
	return true


func swap_pieces(grid_pos1, grid_pos2):
	if !is_valide_piece(grid_pos1) or !is_valide_piece(grid_pos2):
		return
	var first_piece = all_pieces[grid_pos1.x][grid_pos1.y]
	var other_piece = all_pieces[grid_pos2.x][grid_pos2.y]
	if first_piece == null or other_piece == null:
		return
	all_pieces[grid_pos1.x][grid_pos1.y] = other_piece
	all_pieces[grid_pos2.x][grid_pos2.y] = first_piece
	var first_pos = first_piece.position
	first_piece.move(other_piece.position)
	other_piece.move(first_pos)


func find_matches_from_data(data):
	var list_of_matches = []
	for i in range(1, width - 1):
		for j in range(height):
			var number_of_matches = 0
			if data[i][j] == -1:
				continue
			for k in range(-1, 2, 2):
				if data[i + k][j] == -1:
					break
				if data[i + k][j] == data[i][j]:
					number_of_matches += 1
			if number_of_matches >= 2:
				for k in range(-1, 2):
					list_of_matches.append([i + k,j])
	for i in range(width):
		for j in range(1, height - 1):
			if data[i][j] == -1:
				continue
			var number_of_matches = 0
			for k in range(-1, 2, 2):
				if data[i][j + k] == -1:
					break
				if data[i][j + k] == data[i][j]:
					number_of_matches += 1
			if number_of_matches >= 2:
				for k in range(-1, 2):
					list_of_matches.append([i,j + k])
	if list_of_matches.size() != 0:
		return list_of_matches
	return null


func find_matches():
	for i in range(width):
		for j in range(height):
			if all_pieces[i][j] != null:
				all_pieces[i][j].matched = false
				all_pieces[i][j].highlite(false)
	var pieces_IDs = all_pieces_to_data()
	var list_of_matches = find_matches_from_data(pieces_IDs)
	if list_of_matches != null:
		for m in list_of_matches:
			all_pieces[m[0]][m[1]].matched = true
			all_pieces[m[0]][m[1]].highlite(true)
		$DestriyTimer.start()
		locked = true
		return true
	return false


func destroy_matched():
	var pop_positions = []
	for i in range(width):
		for j in range(height):
			if all_pieces[i][j] != null:
				if all_pieces[i][j].matched:
					pop_positions.append(all_pieces[i][j].position)
					all_pieces[i][j].queue_free()
					all_pieces[i][j] = null
					Global.score += 1
	main_node.update_score(Global.score)
	if pop_positions.size() > 0:
		main_node.add_effect("pop")


func collaps_columns():
	var has_empty_cells = false
	for i in range(width):
		for j in range(height):
			if all_pieces[i][j] == null:
				has_empty_cells = true
				for k in range(j + 1, height):
					if all_pieces[i][k] != null:
						all_pieces[i][k].move(grid_to_pixel(i, j), Tween.EASE_OUT)
						all_pieces[i][j] = all_pieces[i][k]
						all_pieces[i][k] = null
						break
	if !has_empty_cells:
		$UnlockTimer.start() 


func refill_columns():
	var has_empty_cells = false
	for i in range(width):
		for j in range(height):
			if all_pieces[i][j] == null:
				has_empty_cells = true
				random_piece(i, j)
	if has_empty_cells:
		if !find_matches():
			$UnlockTimer.start()

func _on_DestriyTimer_timeout():
	destroy_matched()
	$CollapsTimer.start()


func _on_CollapsTimer_timeout():
	collaps_columns()
	$RefillTimer.start()


func _on_RefillTimer_timeout():
	refill_columns()
	


func _on_UnlockTimer_timeout():
#	main_node.show_number_of_good_moves(check_moves())
	locked = false
	var good_moves = check_moves()
	main_node.show_number_of_good_moves(good_moves)
	if good_moves == 0:
		$RestartTimer.start()


func _on_SwapBackTimer_timeout():
	swap_pieces(first_touch_on_grid, final_touch_on_grid)
	$UnlockTimer.start()


func _on_RestartButton_pressed():
	Global.score = 0
	get_tree().reload_current_scene()


func _on_RestartTimer_timeout():
	get_tree().reload_current_scene()
