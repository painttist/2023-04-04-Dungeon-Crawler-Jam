extends Control

class_name Tile

@onready var texture_rect = $TextureRect

var item_type = Globals.SWORD: set = set_item_type

#signal update_sprite(type: int)

func set_item_type(new_value):
	item_type = new_value
	update_tile_display(item_type)
	pass

func update_tile_display(type):
#	print("signal recevied")
	if type != null:
		texture_rect.texture = Globals.sprite_dict[type]
	else:
		texture_rect.texture = null
	pass

func rotate_left():
	rotation_degrees -= 90

func rotate_right():
	rotation_degrees += 90

