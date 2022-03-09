extends Node2D

onready var parent = get_parent()
onready var bg = $background_button
onready var children = get_children()

var names = ['continue_level', 'shuffle_level', 'spirits', 'colors']
var pressed = [0, 0, 0, 0]

func _ready():
	modulate = Color(1, 1, 1, .8)
	set_process(false)

func _process(_delta):
	position = parent.camera.position
	if bg.is_pressed():
		var only_pressed = true
		for child in children:
			if child.is_pressed() and child != bg:
				only_pressed = false
		if only_pressed:
			exit()
	
	for child in children:
		if child != bg:
			if child.is_pressed():
				if child.name == names[3]:
					pressed[3] = 2
				else:
					pressed[names.bsearch(child.name)] = 2
	
	for button in len(pressed):
		if pressed[button] > 0:
			pressed[button] -= 1

func exit():
	set_visible(false)
	set_process(false)

func _on_continue_released():
	if pressed[0]:
		exit()

func _on_shuffle_level_released():
	if pressed[1]:
		parent.level.new_level()
		exit()

func _on_spirits_released():
	if pressed[2]:
		parent.spirits.enter()
		exit()

func _on_colors_released():
	if pressed[3]:
		parent.colors.enter()
		exit()
