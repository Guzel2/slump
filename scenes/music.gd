extends Node2D

onready var parent = get_parent()
onready var children = get_children()

var melody

var channel = 0
var db = 1
var state = 2

var channels = [[1, -80, 0], [0, -80, -3]]
var melodies = ['1', '2', '3']

var base_time = 3000
var variation = 1200
var timer = base_time + randi() % variation


var delta_ = 0

func _ready():
	melodies.shuffle()
	for child in children:
		if child.name == 'melody' + melodies[1]:
			child.set_volume_db(-10)
			child.play()
			melody = child
	
	$extra1.play()

func _process(delta):
	position = parent.player.position
	delta_ = delta
	timer -= 1
	if timer == 0:
		next_melody()
	
	fix_sync_issue()

func next_level():
	for chan in range(len(channels)):
		channels[chan][state] += 1
		if channels[chan][state] == 1:
			channels[chan][db] = -18
			
		elif channels[chan][state] <= 3:
			channels[chan][db] += 6
		elif channels[chan][state] <= 5:
			channels[chan][db] -= 6
		else:
			channels[chan][db] = -80
			channels[chan][state] = 0
		
		for child in children:
			if child.name == 'extra' + str(channels[chan][channel]):
				if channels[chan][state] == 1:
					child.play(melody.get_playback_position()+delta_)
					child.set_volume_db(-30)
				child.goal = channels[chan][db]
	
	for chan in range(len(channels)):
		if channels[chan][state] == 0:
			channels[chan][channel] += 2
			if channels[chan][channel] > 6:
				channels[chan][channel] -= 6
	
	fix_sync_issue()

func next_melody():
	timer = base_time + randi() % variation
	
	for child in children:
		if child.name == 'melody' + melodies[0]:
			child.goal = -80
	
	for child in children:
		if child.name == 'melody' + melodies[1]:
			child.goal = -10
			child.play(melody.get_playback_position()+delta_)
			melody = child
	
	while melody.name != 'melody' + melodies[0]:
		melodies.shuffle()

func fix_sync_issue():
	for chan in range(len(channels)):
		for child in children:
			if child.name == 'extra' + str(channels[chan][channel]):
				if child.get_playback_position() != melody.get_playback_position():
					if melody.get_playback_position() - child.get_playback_position() > .1 or melody.get_playback_position() - child.get_playback_position() < -.1:
						child.seek(melody.get_playback_position())
