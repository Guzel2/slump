extends Label

onready var parent = get_parent()

var bitmap

var width = 5

var all_letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.,:"!?-1234567890 §$%&/('

var wider_letters = 'KMTVWXYZmvwxyz§$%&/('
var thin_letters = 'Ifijlrt.'

var timer = 5.0
var space_size = 2

func _ready():
	bitmap = BitmapFont.new()
	bitmap.add_texture(load("res://assets/font/font.png"))
	
	bitmap.set_height(7)
	bitmap.set_ascent(5)
	
	var x = 0
	
	for letter in all_letters:
		bitmap.add_char(ord(letter), 0 , Rect2(Vector2(x, 0), Vector2(5, 9)))
		bitmap.add_kerning_pair(ord(letter), ord(' '), space_size)
		bitmap.add_kerning_pair(ord(letter), ord('.'), space_size-1)
		x += 5
		
	
	for letter in wider_letters:
		for letter2 in all_letters:
			bitmap.add_kerning_pair(ord(letter), ord(letter2), -1)
		bitmap.add_kerning_pair(ord(letter), ord(' '), space_size-1)
		bitmap.add_kerning_pair(ord(letter), ord('.'), space_size-2)
	
	for letter in thin_letters:
		for letter2 in all_letters:
			bitmap.add_kerning_pair(ord(letter), ord(letter2), 1)
		bitmap.add_kerning_pair(ord(letter), ord(' '), space_size+1)
		bitmap.add_kerning_pair(ord(letter), ord('.'), space_size)
	
	theme = Theme.new()
	theme.default_font = bitmap

func _process(delta):
	if timer <= 0:
		rect_position.y -= 60*delta
		self_modulate[3] -= .05
		if self_modulate[3] <= 0:
			parent.remove_child(self)
	elif timer < 100:
		timer -= delta
