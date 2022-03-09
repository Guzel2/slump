extends KinematicBody2D

onready var col = $CollisionShape2D
onready var ani = $animations
onready var text
onready var parent = get_parent()
onready var children = get_children()
onready var jump_sfx = $jump_sfx
onready var dash_sfx = $dash_sfx

var grid_size = 12
onready var width = col.shape.extents.x*2
onready var height = col.shape.extents.y*2

var ground_time = 0
var air_time = 1
var grounded = false
var wall_clinging = false
var max_wall_clinges = 1
var wall_clinges = max_wall_clinges
var hsp = 0
var vsp = 0
var dir = 1
var last_input = 'neutral'
var jump_input = 0
var directions = ['left', 'right']

var max_dashes = 1
var dashes = max_dashes
var dash_hsp = 0
var dash_vsp = 0
var dash_time = 0
var dash_up_vsp = -5
var dash_side_vsp = -4
var dash_side_hsp = 4
var dash_start_up = 1
var dash_active = 7
var dash_end = 3

var gravity = 0.1
var jump_force = -2.29
var base_acceleration = .135
var acceleration = base_acceleration
var friction = 0.93
var min_speed = 0.1
var turn_around_multiplier = 0.5
var buffer_time = 8
var wall_jump_hsp = 1.2
var wall_slide_backwards = 0.12

#animation
var jump_slight_mind = .2 #mind hsp
var jump_strong_mind = 1.2
var normal_color = Color(.4, 1, 1)
var dash_used_color = Color(.4, 1, .3)
var wall_used_color = Color(.4, .3, 1)
var all_used_color = Color(.4, .4, .4)

#game feel
var falling_time = 0
var shake = Vector2(.6, 0)

#spirits
var timer = 0

#tutorial
var move_time = 0
var jump_count = 0
var dash_count = 0
var wall_cling_count = 0
var wall_jump_count = 0

func _process(delta):
	timers()
	
	inputs()
	
	tutorial(delta)
	
	move()
	jump()
	dash()

	move_and_slide(Vector2(hsp, vsp)*60, Vector2(0, -1))
	if grounded and move_and_slide(Vector2(0, 1)).y != 0:
		grounded = false
	if is_on_floor():
		grounded = true
	if !grounded:
		if is_on_wall() and wall_clinges > 0 and vsp > 0 and hsp != 0:
			wall_clinging = true
			wall_clinges -= 1
	if is_on_ceiling():
		vsp *= .8
	
	draw()
	modulate_this()
	
	extra_game_feel()

func timers():
	if grounded:
		ground_time += 1
		if air_time > 0:
			air_time = 0
			vsp = 0
			wall_clinges = max_wall_clinges
			dashes = max_dashes
			move_and_slide(Vector2(-dir, 0), Vector2(0, -1))
	else:
		if wall_clinging:
			if air_time > 0:
				vsp = 0
				hsp = 0
				air_time = 0
		else:
			air_time += 1
			vsp += gravity
			ground_time = 0

func inputs():
	for direction in directions:
		if Input.is_action_just_pressed(direction):
			last_input = direction
		if Input.is_action_just_released(direction) and last_input == direction:
			last_input = 'neutral'
	if Input.is_action_just_pressed("jump"):
		jump_input = 10
		
	else:
		if jump_input > 0:
			jump_input -= 1

func move():
	if wall_clinging:
		if last_input == 'neutral':
			wall_clinging = false
		if dir == -1 and last_input == 'right':
			wall_clinging = false
		if dir == 1 and last_input == 'left':
			wall_clinging = false
	else:
		if last_input == 'neutral':
			hsp *= friction
		else:
			if last_input == 'left':
				dir = -1
			if last_input == 'right':
				dir = 1
			hsp += acceleration * dir
			
			if wall_clinges < max_wall_clinges and air_time < 7:
				hsp += acceleration * dir
		
		hsp *= friction
		if hsp > -min_speed and hsp < min_speed:
			hsp = 0

func jump():
	if air_time < buffer_time:
		if jump_input:
			vsp = jump_force
			grounded = false
			jump_input = 0
			if wall_clinging:
				hsp = dir*-wall_jump_hsp
				wall_clinging = false
			play_sfx(jump_sfx, 10, frames_seconds_factor(jump_time(), jump_sfx.get_stream().get_length(), 1.6), 0)

func dash():
	if jump_input and dashes and air_time >= buffer_time:
		if last_input == 'neutral': #straight up
			dash_vsp = dash_up_vsp
			dash_hsp = 0
		else: #to the side
			dash_vsp = dash_side_vsp
			dash_hsp = dash_side_hsp*dir
		dashes -= 1
		dash_time = dash_start_up + dash_active + dash_end
		jump_input = 0
		play_sfx(dash_sfx, 5, frames_seconds_factor(dash_time, dash_sfx.get_stream().get_length(), 1.5), 0)
	
	if dash_time > dash_active + dash_end:
		vsp = 0
		hsp = 0
		dash_time -= 1
		
		parent.screen_shake = Vector2(dash_hsp, dash_vsp)
		
	elif dash_time > dash_end:
		vsp = dash_vsp
		hsp = dash_hsp
		dash_time -= 1
		
	elif dash_time > 0:
		vsp *= .6
		hsp *= .8
		dash_time -= 1

func draw():
	if hsp > 0:
		ani.flip_h = false
	elif hsp < 0:
		ani.flip_h = true
	if grounded == true:
		if hsp <= .2 and hsp >= -.2:
			ani.animation = 'idle'
			ani.play()
		else:
			ani.animation = 'run'
			ani.play()
	else:
		if dash_time == 0:
			if wall_clinging:
				ani.animation = 'wall'
			elif hsp <= jump_slight_mind and hsp >= -jump_slight_mind:
				if vsp < 0:
					ani.animation = 'jump'
					ani.frame = 4-(vsp/jump_force)*4
				else:
					ani.animation = 'fall'
					ani.frame = floor(vsp)
			elif hsp <= jump_strong_mind and hsp >= -jump_strong_mind:
				if vsp < 0:
					ani.animation = 'jump_slight'
					ani.frame = 4-(vsp/jump_force)*4
				else:
					ani.animation = 'fall_slight'
					ani.frame = floor(vsp)
			else:
				if vsp < 0:
					ani.animation = 'jump_strong'
					ani.frame = 4-(vsp/jump_force)*4
				else:
					ani.animation = 'fall_strong'
					ani.frame = floor(vsp)
					
		else: #is dashing
			if dash_time > dash_active + dash_end: #start up
				ani.frame = 0
				ani.animation = "dash_up"
			else:
				if dash_time > dash_end:
					if hsp == 0:
						ani.animation = "dash_up"
					else:
						ani.animation = "dash_right"
				ani.frame = 1

func modulate_this():
	if dashes > 0 and wall_clinges > 0:
		ani.self_modulate = normal_color
	elif dashes == 0 and wall_clinges > 0:
		ani.self_modulate = dash_used_color
	elif wall_clinges == 0 and dashes > 0:
		ani.self_modulate = wall_used_color
	else:
		ani.self_modulate = all_used_color

func extra_game_feel():
	if vsp > 4:
		parent.screen_shake = shake
		shake.x *= - (.98  + (float(randi() % 14))/100)
		shake.y = ((float(randi() % 201)-100)/100) * shake.x
		falling_time += 1
	else:
		falling_time = 0
	
	if falling_time and grounded:
		shake = Vector2(.6, 0)
		
		parent.screen_slide = Vector2(0, vsp*.9)
		
		for x in ceil(float(falling_time)/12):
			var dust = load("res://scenes/player/dust.tscn").instance()
			dust.direction.x = -1
			dust.position = position + Vector2(grid_size*1/4, grid_size*3/4)
			parent.add_child(dust)
			var dust2 = load("res://scenes/player/dust.tscn").instance()
			dust2.direction.x = 1
			dust2.position = position + Vector2(grid_size*3/4, grid_size*3/4)
			parent.add_child(dust2)
		
		falling_time = 0

func _on_Timer_timeout():
	timer += 1

func next_level():
	for child in get_children():
		if "spirit" in child.name:
			child.levels_to_stay -= 1

func tutorial(delta):
	if !parent.other_stuff['tutorial']:
		text = parent.camera.text
		text.timer = 100
		if move_time < 1.3:
			text.text = 'Press § and / to move left and right'
			if hsp < -.9 or hsp > .9:
				move_time += delta
		elif jump_count < 3:
			text.text = 'Press % to jump'
			if vsp < -2.1:
				jump_count += 1
		elif dash_count < 3:
			text.text = 'Press % in the air to dash. You can dash in 3 directions: $ % &'
			if dash_time == dash_start_up + dash_active + dash_end - 1:
				dash_count += 1
		elif wall_cling_count < 1:
			text.text = 'Hold in the direction of a wall to stick to it'
			if wall_clinges == 0:
				wall_cling_count += 1
		elif wall_jump_count < 1:
			text.text = 'Press % to perform a wall jump'
			if wall_clinges == 0 and vsp < -2.1 and air_time < buffer_time:
				wall_jump_count += 1
		else:
			parent.other_stuff['tutorial'] = true
			parent.save(parent.other_stuff, parent.other_save)
			text.text = 'Your goal is to reach a teleporter at the top that looks a bit like this: ('
			text.timer = 8

func play_sfx(sfx, randomness, original_pitch, starting_point):
	sfx.set_pitch_scale(original_pitch*(1-randomness/100 + float(randi() % randomness*2)/100))
	sfx.play(starting_point)

func frames_seconds_factor(frames, seconds, overshoot):
	return(seconds/(float(frames)/60*overshoot))

func jump_time():
	var new_force = jump_force
	var counter = 0
	while new_force < 0:
		new_force += gravity
		counter += 1
	return(counter)
