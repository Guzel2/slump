extends Camera2D

onready var parent = get_parent()
onready var left = $left
onready var right = $right
onready var jump = $jump
onready var buttons = get_children()
onready var text = $text_display

var player
var positions = []
var delay_frames = 0
var grid_size = 12
var down = {
	'left': false,
	'right': false,
	'jump': false,
	'settings': false
}
var force = .4
var old_y = 0

func _ready():
	for child in parent.get_children():
		if child.name == 'player':
			player = child
	
	for _frame in delay_frames:
		positions.append(Vector2(0, 0))
	
	parent.screen_width = 1280*zoom.x
	parent.screen_height = 720*zoom.y
	
	self_modulate = Color(1, 1, 1, .5)
	
	buttons.remove(0)
	for button in buttons:
		if button.name == 'jump':
			button.modulate = player.dash_used_color
		elif button.name == 'settings':
			pass
		else:
			button.modulate = player.normal_color
		
		button.modulate[3] = .5
	
	set_buttons_to_screen()

func _process(_delta):
	positions.append(Vector2(player.position.x, player.position.y-20))
	position = positions.pop_front()
	
	for button in buttons:
		if !('text' in button.name) and !('Aspect' in button.name):
			if button.is_pressed():
				if down[button.name] == false:
					down[button.name] = true
					match button.name:
						'left', 'right':
							player.last_input = button.name
						'jump':
							player.jump_input = 10
						'settings':
							parent.menu.position = position
							parent.menu.set_process(true)
							parent.menu.visible = true
							get_tree().set_auto_accept_quit(true)
			elif down[button.name] == true:
				down[button.name] = false
				if player.last_input == button.name:
					player.last_input = 'neutral'
	
	if parent.screen_shake != null:
		screen_shake()
	if parent.screen_slide != null:
		old_y = position.y
		screen_slide()

func screen_shake():
	position -= parent.screen_shake * force
	parent.screen_shake = null

func screen_slide():
	position += parent.screen_slide
	parent.screen_slide *= .95
	if parent.screen_slide.x + parent.screen_slide.y < .05:
		parent.screen_slide = null

func set_buttons_to_screen():
	var screenSize = get_viewport().get_visible_rect().size * zoom
	var move_buttons_width = 48
	for button in buttons:
		match button.name:
			'left':
				button.position.x = screenSize.x/-2
				button.position.y = screenSize.y/2 - move_buttons_width
			'right':
				button.position.x = screenSize.x/-2 + move_buttons_width
				button.position.y = screenSize.y/2 - move_buttons_width
			'jump':
				button.position.x = screenSize.x/2 - move_buttons_width
				button.position.y = screenSize.y/2 - move_buttons_width
			'settings':
				button.position.x = screenSize.x/-2
				button.position.y = screenSize.y/-2
