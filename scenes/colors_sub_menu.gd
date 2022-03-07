extends Node2D

onready var parent = get_parent()
onready var bg = $background
onready var children = get_children()
onready var ani = $animations
onready var RGB = $RGB_button
onready var HSV = $HSV_button
onready var scale_bg = $scale_bg

var cursors = []
var cursor_offset = 4

var buttons = []

var color
var color_mode = 'HSV'
var color_values = [1, 1, 1]

var just_pressed = 0

func _ready():
	for child in children:
		if 'button' in child.name:
			buttons.append(child)
		if 'cursor' in child.name:
			cursors.append(child)
			buttons.append(child)
	set_process(false)

func _process(_delta):
	position = parent.camera.position
	if bg.is_pressed():
		var only_pressed = true
		for button in buttons:
			if button.is_pressed():
				only_pressed = false
		if only_pressed:
			exit()
	
	var values = check_cursors()
	values_to_color(values)

func exit():
	set_visible(false)
	set_process(false)
	parent.camera.visible = true
	parent.save(parent.other_stuff, parent.other_save)

func enter():
	for value in range(3):
		color_values[value] = parent.other_stuff[color][value]
	set_cursors()
	set_visible(true)
	set_process(true)
	parent.camera.visible = false

func check_cursors():
	var values = [0, 0, 0]
	for cursor in cursors:
		if cursor.is_pressed():
			cursor.position.x = get_global_mouse_position().x - parent.camera.position.x - cursor_offset
			if cursor.position.x > 77:
				cursor.position.x = 77
			if cursor.position.x < -23:
				cursor.position.x = -23
		values[int(cursor.name)] = (float(cursor.position.x+23) / 100)
	return(values)

func set_cursors():
	if color_mode == 'RGB':
		var color_blend = Color(color_values[0], color_values[1], color_values[2])
		var rgb_values = [color_blend.r, color_blend.g, color_blend.b]
		for cursor in cursors:
			cursor.position.x = -23 + rgb_values[int(cursor.name)]*100
		scale_bg.animation = 'RGB'
	else:
		var color_blend = Color(color_values[0], color_values[1], color_values[2])
		var hsv_values = [color_blend.h, color_blend.s, color_blend.v]
		for cursor in cursors:
			cursor.position.x = -23 + hsv_values[int(cursor.name)]*100
		scale_bg.animation = 'HSV'

func values_to_color(values):
	var color_blend
	if color_mode == 'RGB':
		color_blend = Color(values[0], values[1], values[2])
	else:
		color_blend = Color.from_hsv(values[0], values[1], values[2])
	ani.modulate = color_blend
	parent.other_stuff[color] = color_blend
	parent.set_player_color()

func _on_back_button_released():
	exit()
	parent.colors.enter()

func _on_reset_button_released():
	match(color):
		'normal_color':
			color_values = Color(.4, 1, 1)
		'dash_used_color':
			color_values = Color(.4, 1, .3)
		'wall_used_color':
			color_values = Color(.4, .3, 1)
		'all_used_color':
			color_values = Color(.4, .4, .4)
	set_cursors()

func _on_RGB_button_released():
	color_mode = 'HSV'
	set_cursors()
	RGB.visible = false
	HSV.visible = true

func _on_HSV_button_released():
	color_mode = 'RGB'
	set_cursors()
	RGB.visible = true
	HSV.visible = false
