extends Node2D

onready var player = $player
onready var level = $level
onready var music = $music
onready var camera = $camera
onready var menu = $menu
onready var spirits = $spirits
onready var spirits_sub = $spirit_sub_menu
onready var colors = $colors
onready var colors_sub = $colors_sub_menu

var screen_height = 0
var screen_width = 0

var screen_shake
var screen_slide

var next_level_cooldown = 0

var collected_spirits = [false, false, false, false, false, false, false, false, false, false, false, false]
#var collected_spirits = [true, true, true, true, true, true, true, true, true, true, true, true]
var spirit_save  = "user://spirits.dat"
var other_save = "user://save_game.dat"

var other_stuff = {
	'tutorial': false,
	'normal_color': Color(.4, 1, 1),
	'dash_used_color': Color(.4, 1, .3),
	'wall_used_color': Color(.4, .3, 1),
	'all_used_color': Color(.4, .4, .4),
}

func _ready():
	if read(spirit_save) != null:
		collected_spirits = read(spirit_save)
	save(collected_spirits, spirit_save)
	
	if read(other_save) != null:
		other_stuff = read(other_save)
		set_player_color()
	save(other_stuff, other_save)

func _process(_delta):
	player_after_images()
	if next_level_cooldown > 0:
		next_level_cooldown -= 1

func player_after_images():
	if player.dash_time > 0 and player.dash_time % 3 == 0:
		var image = load("res://scenes/player/dash_after_image.tscn").instance()
		self.add_child(image)
		image.position = player.position

#spirits
func save(content, path):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_var(content)
	file.close()

func read(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_var()
	file.close()
	return(content)

func set_player_color():
	player.normal_color = other_stuff['normal_color']
	player.dash_used_color = other_stuff['dash_used_color']
	player.wall_used_color = other_stuff['wall_used_color']
	player.all_used_color = other_stuff['all_used_color']
