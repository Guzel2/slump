extends AnimatedSprite

onready var parent = get_parent()

var rotation_percentage = 40
var _rotation = float(randi() % rotation_percentage)
var direction = Vector2(0, _rotation/-rotation_percentage)
var timer = 20 + randi() % 20
var aimation_frames = timer / 5
var framez = -1
var scale_percentage = 50
var scale_factor = float(scale_percentage + randi() % scale_percentage+1) / 100

func _ready():
	if direction.x < 0:
		rotation_degrees = _rotation
	else:
		rotation_degrees = 180-_rotation
	
	scale = Vector2(scale_factor, scale_factor)

func _process(_delta):
	timer -= 1
	if timer == 0:
		parent.remove_child(self)
	position += direction
	direction *= .9
	
	if timer % aimation_frames == 0:
		framez += 1
		frame = framez
