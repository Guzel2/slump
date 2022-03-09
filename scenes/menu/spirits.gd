extends Node2D

onready var parent = get_parent()
onready var bg = $background_button
onready var children = get_children()

var names = []
var pressed = []

func _ready():
	modulate = Color(1, 1, 1, 1)
	set_process(false)
	
	for child in children:
		if child != bg:
			names.append(child.name)
			pressed.append(0)
	
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
				if int(child.name) != 0:
					pressed[int(child.name)-1] = 3
				else:
					if child.name != 'back':
						pressed[12] = 3
					else:
						pressed[13] = 3
	
	for button in len(pressed):
		if pressed[button] > 0:
			pressed[button] -= 1
	
	for child in children:
		if int(child.name) != 0:
			if pressed[int(child.name)-1] > 0 and !child.is_pressed() and parent.collected_spirits[int(child.name)-1] == true:
				exit()
				parent.spirits_sub.enter(int(child.name))

func set_child_animations():
	for child in children:
		var num = int(child.name)
		if num != 0:
			var ani
			for baby in child.get_children():
				ani = baby
			ani.frame = 0
			if parent.collected_spirits[num-1]:
				ani.animation = str(num)
			else:
				ani.animation = 'question'

func exit():
	set_visible(false)
	set_process(false)
	parent.camera.visible = true

func enter():
	set_visible(true)
	set_process(true)
	parent.camera.visible = false
	set_child_animations()

func _on_reset_released():
	if pressed[13-1]:
		parent.collected_spirits = [false, false, false, false, false, false, false, false, false, false, false, false]
		parent.save(parent.collected_spirits, parent.spirit_save)
		set_child_animations()

func _on_back_released():
	if pressed[14-1]:
		exit()
		parent.menu.visible = true
		parent.menu.set_process(true)
