extends Area2D

onready var ani = $AnimatedSprite
onready var parent = get_parent()
onready var level = parent
onready var grandparent = parent.get_parent()
onready var player

var spirit_level = 1

func _process(_delta):
	ani.animation = str(spirit_level)
	set_process(false)

func _on_spirit_body_entered(body):
	if body.name == 'player':
		parent.parent.collected_spirits[spirit_level-1] = true
		parent.parent.save(parent.parent.collected_spirits, parent.parent.spirit_save)
		var new_spirit = load("res://scenes/spirit_following.tscn").instance()
		player.add_child(new_spirit)
		new_spirit.spirit_level = spirit_level
		new_spirit.ani.animation = str(spirit_level)
		new_spirit.add_changes()
		
		parent.remove_child(self)
		for child in parent.get_children():
			if 'spirit' in child.name:
				parent.remove_child(child)
