extends Node2D

onready var parent = get_parent()
onready var bg = $background
onready var back = $back
onready var children = get_children()
onready var buttons = []
onready var colors = []

var just_pressed = 0
var last_pressed

func _ready():
	for child in children:
		if 'button' in child.name:
			buttons.append(child)
		if 'color' in child.name:
			colors.append(child)
	set_process(false)

func _process(_delta):
	position = parent.camera.position
	if bg.is_pressed():
		var only_pressed = true
		for button in buttons:
			if button.is_pressed():
				only_pressed = false
		if back.is_pressed():
			only_pressed = false
		if only_pressed:
			exit()
	
	for button in buttons:
		if button.is_pressed():
			just_pressed = 2
			last_pressed = button
		else:
			if just_pressed:
				var none_pressed = true
				for button2 in buttons:
					if button2.is_pressed():
						none_pressed = false
				if none_pressed:
					if button == last_pressed:
						var text = ''
						for letter in button.name:
							if letter == 'b':
								break
							text += letter
						parent.colors_sub.color = text + 'color'
						exit()
						parent.colors_sub.enter()
	
	if just_pressed > 0:
		just_pressed -= 1

func exit():
	set_visible(false)
	set_process(false)
	parent.camera.visible = true

func enter():
	set_visible(true)
	set_process(true)
	parent.camera.visible = false
	set_colors()

func set_colors():
	for color in colors:
		color.modulate = parent.other_stuff[color.name]

func _on_back_released():
	exit()
