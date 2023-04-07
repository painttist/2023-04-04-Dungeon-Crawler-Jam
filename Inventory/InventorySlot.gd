extends Control

class_name InventorySlot

var inventory: Inventory
var slot_id
var tile: Tile

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory = get_parent().get_parent()
	for child in get_children():
		if is_instance_of(child, Tile):
			tile = child
			break


func _can_drop_data(at_position, data) -> bool:
#	print("can drop data")
	return data.is_in_group("Loot") and inventory.check_availble_for_place(slot_id, data)

func _drop_data(at_position, data):
#	print("drop data")
	inventory.handle_drop_placement(slot_id, data)
#
#func on_tile_mouse_release(event):
#	if Input.is_action_just_released("Click"):
#		print("release")

