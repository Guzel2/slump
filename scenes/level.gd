extends Node2D

onready var tile = $tilemap
onready var parent = get_parent()
var player
var grid_size = 12
#grid is 21/22 x 12 big
var level = []
var p = -1 #player
var e = 0 #empty
var b = 1 #block
var g = 2 #goal
var c = 3 #crystal
var s = 4 #spirit
var block_percentage = .015
var extra_blocks = 6
var level_x = 100 #level x size
var level_y = 50 #level y size
var level_difficulty = 0
var directions = ['up', 'up', 'down', 'left', 'right']
var step_size = 3 #each color is on screen for this amount of levels
var square_size = 11 #sqaures for extra crystals
var crystal_spawn_chance = .2
var spirits = 0

func _ready():
	randomize()
	for child in parent.get_children():
		if child.name == 'player':
			player = child
	new_level()

func new_level():
	clear_goals()
	clear_crystals()
	clear_spirits()
	tile.clear()
	level.clear()
	for y in level_y:
		var line = []
		if y != 0 and y != level_y-1:
			var blocks = floor(block_percentage*level_x)
			for block in blocks:
				line.append(b)
			for empty in level_x-blocks:
				line.append(e)
			line.shuffle()
			line[0] = b
			line[level_x-1] = b
			level.append(line)
		else:
			for _x in level_x:
				line.append(b)
			level.append(line)
	
	for _tries in floor(extra_blocks):
		level = add_extra_blocks()
	level = add_goals()
	level = add_crystals1()
	add_crystals3()
	
	add_spirits()
	
	set_player_spawn()
	
	make_tile_map()
	
	#activate goals/crystals
	for child in get_children():
		if !('map' in child.name):
			child.player = player
			child.set_process(true)

func add_extra_blocks():
	var new_level = []
	for y in level:
		new_level.append(y)
	
	for y in len(level):
		if y != 0 and y < level_y-1:
			for x in len(level[y]):
				if x != 0 and x < level_x-1:
					if level[y][x] == b:
						directions.shuffle()
						match directions[0]:
							'up':
								new_level[y-1][x] = b
							'down':
								new_level[y+1][x] = b
							'left':
								new_level[y][x-1] = b
							'right':
								new_level[y][x+1] = b
							'empty':
								pass
	return new_level

func add_goals():
	var new_level = []
	for y in level:
		new_level.append(y)
	var x = 1
	for y in len(level):
		if y != 0 and y < (level_y-1)/4:
			while x < level_x-1:
				if level[y][x] == b and level[y-1][x] == e:
					new_level[y-1][x] = g
					x += 8
					break
				else:
					x += 1
			if x > level_x-10:
				x = 1
	return new_level

func add_crystals1(): #replace single blocks with crystals 
	var new_level = []
	for y in level:
		new_level.append(y)
	for y in len(level):
		var x = 1
		if y != 0 and y < level_y-1:
			while x < level_x-1:
				if level[y][x] == b:
					if level[y][x-1] == e and level[y][x+1] == e:
						if level[y-1][x] == e and level[y+1][x] == e:
							new_level[y][x] = c
				x += 1
	
	return new_level

func add_crystals2(): #add crystals above blocks with much space above them
	var new_level = []
	for y in level:
		new_level.append(y)
	
	var x = 0
	while x < level_x:
		var empty_blocks = 0
		for y in level_y-1:
			if level[y][x] == e:
				empty_blocks += 1
			elif level[y][x] == b:
				if empty_blocks >= 12:
					new_level[y-5][x] = c
					empty_blocks = 0
					x += 5
					break
					print('test')
					print(level_x)
				else:
					empty_blocks = 0
			else:
				empty_blocks = 0
		x += 1
	
	return new_level

func add_crystals3(): #add crystals to empty spaces
	var y = 1
	while y < level_y-square_size:
		var x = 1
		var square = 0
		while x < level_x-square_size:
			square += 1
			for block in square_size:
				if level[y+block][x] != e:
					square = 0
					break
			if square == square_size:
				level[y+floor(square_size/2)][x-floor(square_size/2)] = c
			x += 1
		y += 1

func add_spirits():
	while spirits > 0:
		var pos = Vector2(randi() % level_x, randi() % level_y)
		if level[pos.y][pos.x] == e:
			level[pos.y][pos.x] = s
			spirits -= 1

func clear_goals():
	for child in get_children():
		if 'goal' in child.name:
			remove_child(child)

func clear_crystals():
	for child in get_children():
		if 'crystal' in child.name:
			remove_child(child)

func clear_spirits():
	for child in get_children():
		if 'spirit' in child.name:
			if spirits < 3:
				spirits += 1
			remove_child(child)

func set_player_spawn():
	var checking = true
	var spawn_pos = Vector2(randi() % level_x, floor(level_y*4/5))
	
	while checking:
		if level[spawn_pos.y][spawn_pos.x] == e:
			level[spawn_pos.y][spawn_pos.x] = p
			checking = false
		else:
			spawn_pos.x = randi() % level_x

func make_tile_map():
	for y in len(level):
		for x in len(level[y]):
			match level[y][x]:
				e:
					pass
				b:
					var new_difficulty = level_difficulty % 54
					var block_value = 0
					if new_difficulty % step_size == 0:
						block_value = new_difficulty/step_size
					elif new_difficulty % step_size == 1:
						if randi() % step_size <= 1:
							block_value = floor(new_difficulty/step_size)
						else:
							block_value = floor(new_difficulty/step_size)+1
					else:
						if randi() % step_size <= 0:
							block_value = floor(new_difficulty/step_size)
						else:
							block_value = floor(new_difficulty/step_size)+1
					if level_difficulty > 54:
						if block_value == 0:
							block_value = 18
					
					tile.set_cell(x, y, block_value)
						
				g:
					var goal = load("res://scenes/goal.tscn").instance()
					self.add_child(goal)
					goal.position = Vector2(x, y)*grid_size + Vector2(grid_size/2, grid_size/2)
				p:
					player.position = Vector2(x, y)*grid_size
				c:
					if randi() % 100 <= crystal_spawn_chance:
						var crystal = load("res://scenes/crystal.tscn").instance()
						self.add_child(crystal)
						crystal.position = Vector2(x, y)*grid_size + Vector2(grid_size/2, grid_size/2)
				s:
					var spirit = load("res://scenes/spirit.tscn").instance()
					self.add_child(spirit)
					spirit.position = Vector2(x, y)*grid_size + Vector2(randi() % 5, randi() % 5)
					
					var roll = randi() % 100
					var spirit_level = 1 + floor(level_difficulty/3)
					var modifier = ((randi() % 1) +1) *2 -3
					
					if roll < 60: #spot on
						spirit.spirit_level = spirit_level
					elif roll < 80: #1 off
						spirit.spirit_level = spirit_level + 1*modifier
					elif roll < 90: #2 off
						spirit.spirit_level = spirit_level + 2*modifier
					elif roll < 95: #3 off
						spirit.spirit_level = spirit_level + 3*modifier
					elif roll < 98: #4 off
						spirit.spirit_level = spirit_level + 4*modifier
					else: #5 off
						spirit.spirit_level = spirit_level + 5*modifier
					
					if spirit.spirit_level < 1:
						spirit.spirit_level = 2*spirit_level - spirit.spirit_level
					
					if spirit.spirit_level > 12:
						spirit.spirit_level = int(spirit_level) % 12

func next_level():
	if parent.next_level_cooldown == 0:
		level_difficulty += 1
		print(level_difficulty)
		
		if level_difficulty <= 6:
			if level_difficulty % 2 == 1:
				extra_blocks -= 1
			else:
				directions.append('empty')
			block_percentage *= 1.1
		elif level_difficulty <= 7:
			directions.append('empty')
			directions.append('down')
			block_percentage *= 1.09
		else:
			block_percentage *= 0.96
			if block_percentage < .0001 * level_x:
				block_percentage *= 1.5
				directions.append('empty')
		
		crystal_spawn_chance = level_difficulty*2
		if crystal_spawn_chance > 40:
			crystal_spawn_chance = 40
		
		spirits = 25
		if player.timer < 20:
			spirits = 8
		elif player.timer < 30:
			spirits = 7
		elif player.timer < 40:
			spirits = 6
		elif player.timer < 55:
			spirits = 5
		elif player.timer < 75:
			spirits = 4
		else:
			spirits = 3
		
		player.timer = 0
		
		parent.music.next_level()
		parent.player.next_level()
		
		new_level()
	parent.next_level_cooldown = 10
