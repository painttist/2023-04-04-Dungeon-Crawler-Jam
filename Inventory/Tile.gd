extends Node2D

class_name Tile

@onready var texture_rect = $TextureRect

var item_type = Globals.SWORD_UP: set = set_item_type
var durability: int = 9999

func set_item_type(new_value):
	item_type = new_value
	update_tile_display(item_type)
	init_durability()
	pass

func update_tile_display(type):
#	print("signal recevied")
	if type != null:
		texture_rect.texture = Globals.sprite_dict[type]
	else:
		texture_rect.texture = null
	pass

# return true if durality is broken
func consume_tile_durability() -> bool:
	durability -= 1
	return durability <= 0

func _process(_delta):
	pass
#	if item_rotation != null:
#		rotation_degrees = item_rotation

func rotate_left():
	rotation_degrees -= 90

func rotate_right():
	rotation_degrees += 90
#	item_rotation = int(item_rotation) % 360
	
func set_item_rotation(degree):
	rotation_degrees = degree

func init_durability():
	match item_type:
		Globals.POTION:
			durability = 1
		Globals.SHIELD:
			durability = 4
		_:
			9999
