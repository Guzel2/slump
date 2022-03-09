extends Node2D

onready var parent = get_parent()
onready var bg = $background
onready var text = $text_display
onready var spirit_button = $spirit_button
onready var children = get_children()

var spirit = 0

var flavor_text = {
	1: 'Blido                                   Using their wings they will increase the slimes jump height and the distance gained by dashing. Because of their friendly nature they will stay for three more levels after meeting them.',
	2: 'Kreus                                   These creatures spin around all day and are master of speed. They will increase the horizontal speed of the slime. Since they are so fastpaced they will only stay for two levels. I wonder if they get dizzy spinning all day.',
	3: 'Flogos                                  They are a sub-species of the Blidos. Their bigger wings are the reason for their better air-mobility. They greatly increase the slimes dash distance. However they are quick to flee and leave after two levels.',
	4: 'Quello                                  After conquering the seas they decided to expand into the air. Due to their leight and nimble bodies they increase the slimes horizontal speed and jump height. Sadly they are really shy and leave after a single level.',
	5: 'Plaf                                    Using their talons they can rest on any wall and cliff. That is also the reason why they enable the slime to wall jump one more time and also increase the horizontal speed of wall jumps. These calm creatures stay for three levels.',
	6: 'Wyrm                                    With their elegant movement they achieved precise air-mobility. They help the slime by enabling the slime to dash a second time while airborn. They will stay for two levels before setting out for new goals.',
	7: 'Invedi                                  These creatures use the power of science to fly. Their machine suits come with a propeller which increases the slimes jump height as well as the horizontal speed from wall jumps. Due to their curiosity they stay for three levels.',
	8: 'Cyclook                                 By using wings and psychic powers the Cyclook can stay in the air for a long time. They grant the slime an additional dash and wall jump. However these prideful creatures will only be staying for a single level.',
	9: 'Rae                                     In these aircrafts live micro creatures, they stay airborn by emitting rays of heat. They increase the slimes jump height and grant it an additional wall jump. They will stay for two levels.',
	10: 'Defio                                  Despite their clunky look these golems can move quickly and precisely in the air due to their psychic powers. The slimes horizontal speed and wall jump distance is increased. They are helpful and stay for three levels.',
	11: 'Frugo                                  Using two propellers these frog-like creatures move elegantly through the air. They will grant the slime two more dashes but decrease the distance from each slightly. They are a bit shy and only stay for two levels.',
	12: 'Vugil                                  These slow creatures stay in the air for elongated periods of time. They increase the slimes jump height and enable the slime to wall jump another time. They are slow to go away and stay three levels.'
}

var buttons = []
var names = []
var pressed = []

func _ready():
	text.timer = 100
	for child in children:
		if 'button' in child.name:
			buttons.append(child)
			names.append(child.name)
			pressed.append(0)
	set_process(false)

func _process(_delta):
	position = parent.camera.position
	if bg.is_pressed():
		var only_pressed = true
		for child in buttons:
			if child.is_pressed() and child != bg:
				only_pressed = false
		if only_pressed:
			exit()
	
	for child in buttons:
		if child.is_pressed():
			var num = 0
			while num < len(names):
				if child.name == names[num]:
					break
				else:
					num += 1
			pressed[num] = 3
	for num in len(pressed):
		if pressed[num] > 0:
			pressed[num] -= 1

func exit():
	set_visible(false)
	set_process(false)
	parent.spirits.enter()

func enter(num):
	spirit = num
	
	var ani
	for baby in spirit_button.get_children():
		ani = baby
	ani.frame = 0
	ani.animation = str(spirit)
	
	text.text = flavor_text[spirit]
	
	position = parent.camera.position
	parent.camera.set_visible(false)
	set_visible(true)
	set_process(true)

func _on_back_button_released():
	if pressed[1]:
		exit()
