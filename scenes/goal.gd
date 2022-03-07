extends Area2D

onready var sprite = $AnimatedSprite
onready var parent = get_parent()
onready var player

func _ready():
	set_process(false)

func _process(_delta):
	modulate = player.normal_color
	set_process(false)

func _on_goal_body_entered(body):
	if body.name == 'player':
		parent.next_level()
		parent.remove_child(self)
