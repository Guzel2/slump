extends Node2D

onready var ani = $AnimatedSprite
onready var player = get_parent()

var spirit_level

var x = 0.0
var speed = .02
var speed_randomness = 12
var diameter = 20
var diameter_randomness = 5

var timer = -1
var levels_to_stay = 0

#gameplay effects
var jump_force = 0
var dash_active = 1
var max_dashes = 2
var max_wall_clinges = 3
var wall_jump_hsp = 4
var base_acceleration = 5
var life_time = 6

var changes = [
	[1.05, 1, 0, 0, 1, 1, 4],		#1
	[1, 0, 0, 0, 1, 1.15, 3],		#2
	[1, 2, 0, 0, 1, 1, 3],			#3
	[1.1, 0, 0, 0, 1, 1.05, 2],		#4
	[1, 0, 0, 1, 1.1, 1, 4],		#5
	[1, 0, 1, 0, 1, 1, 3],			#6
	[1.05, 0, 0, 0, 1.1, 1, 4],	#7
	[1, 0, 1, 1, 1, 1, 2],			#8
	[1.1, 0, 0, 0, 1, 1, 3],		#9
	[1, 0, 0, 0, 1.1, 1.08, 4],		#10
	[1, -1, 2, 0, 1, 1, 3],		#11
	[1.05, 0, 0, 1, 1, 1, 4],		#12
]

var normal = [1, 0, 0, 0, 1, 1]

#display text
var line1 = ''
var line2 = ''

func _ready():
	speed *= 1-float(speed_randomness)/20 + float(randi() % speed_randomness)/speed_randomness
	diameter *= 1-float(diameter_randomness)/20 + float(randi() % diameter_randomness)/diameter_randomness

func _process(_delta):
	position = Vector2(sin(x), cos(x)) * diameter
	x += speed
	
	#self kill mechanism
	if levels_to_stay <= 0:
		if timer == -1:
			timer = randi() % 600
			print('goodbye')
			
		if timer > 0:
			timer -= 1
		else:
			diameter *= 1.01
			if diameter > 150:
				player.remove_child(self)
				remove_changes()

func add_changes():
	player.jump_force *= changes[spirit_level-1][jump_force]
	player.dash_active += changes[spirit_level-1][dash_active]
	player.max_dashes += changes[spirit_level-1][max_dashes]
	player.max_wall_clinges += changes[spirit_level-1][max_wall_clinges]
	player.wall_jump_hsp *= changes[spirit_level-1][wall_jump_hsp]
	player.base_acceleration *= changes[spirit_level-1][base_acceleration]
	player.acceleration = player.base_acceleration
	
	levels_to_stay = changes[spirit_level-1][life_time]
	
	print_description()

func remove_changes():
	player.jump_force /= changes[spirit_level-1][jump_force]
	player.dash_active -= changes[spirit_level-1][dash_active]
	player.max_dashes -= changes[spirit_level-1][max_dashes]
	player.max_wall_clinges -= changes[spirit_level-1][max_wall_clinges]
	player.wall_jump_hsp /= changes[spirit_level-1][wall_jump_hsp]
	player.base_acceleration /= changes[spirit_level-1][base_acceleration]
	player.acceleration = player.base_acceleration

func print_description():
	spirit_description()
	
	print_line(line1, 0)
	print_line(line2, -12)

func spirit_description():
	for change in len(normal):
		if changes[spirit_level-1][change] != normal[change]:
			if line1 == '':
				line1 = match_attribute(change)
			else:
				line2 = match_attribute(change)

func match_attribute(change):
	var text
	if changes[spirit_level-1][change] > normal[change]:
		match change:
			jump_force:
				text = 'Jump height increased'
			dash_active:
				text = 'Dash distance increased'
			max_dashes:
				text = 'Dash amount increased'
			max_wall_clinges:
				text = 'Walljump amount increased'
			wall_jump_hsp:
				text = 'Walljump speed increased'
			base_acceleration:
				text = 'Speed increased'
	else:
		text = 'Dash distance decreased'
	
	return(text)

func print_line(text, margin_top):
	var text_display = load("res://scenes/text_display.tscn")
	var t = text_display.instance()
	t.text = text
	t.rect_position.y += margin_top
	player.parent.camera.add_child(t)
