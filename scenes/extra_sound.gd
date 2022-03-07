extends AudioStreamPlayer

var goal = null
var volume_step = .1

func _process(_delta):
	if goal != null:
		if goal > volume_db:
			volume_db += volume_step
		elif goal < volume_db:
			volume_db -= volume_step
		else:
			if goal == -80:
				stop()
			goal = null
