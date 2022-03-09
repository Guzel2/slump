extends Area2D

onready var sprite = $AnimatedSprite
onready var parent = get_parent()
onready var grandparent = parent.get_parent()
onready var player

var player_in_this = false
var cooltimer = 1
var cooldown = 60*2

func _process(_delta):
	if cooltimer > 1:
		cooltimer -= 1
	elif cooltimer == 1:
		cooltimer = 0
		sprite.animation = 'idle'
		modulate = player.dash_used_color
	else:
		if player_in_this:
			if player.dashes != player.max_dashes:
				player.dashes = player.max_dashes
				sprite.animation = 'cooldown'
				modulate = Color(1, 1, 1)
				cooltimer = cooldown

func _on_crystal_body_exited(body):
	if body.name == 'player':
		player_in_this = false

func _on_crystal_body_entered(body):
	if body.name == 'player':
		player_in_this = true
