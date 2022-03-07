extends Node2D

onready var parent = get_parent()
onready var player = parent.player
onready var ani = $animations

var max_timer = 20
var timer = max_timer

func _ready():
	ani.animation = player.ani.animation
	ani.frame = player.ani.frame
	ani.flip_h = player.ani.flip_h
	modulate_this()

func _process(_delta):
	#self kill mechanism
	timer -= 1
	if timer == 0:
		parent.remove_child(self)
	modulate_this()
	

func modulate_this():
	modulate = player.dash_used_color*float(timer)/max_timer
