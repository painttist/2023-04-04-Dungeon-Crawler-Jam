extends Node2D

class_name InventorySlot

var inventory: Inventory
var slot_id
var tile: Tile

@onready var label = $Control/Label

@export var key: String

# Called when the node enters the scene tree for the first time.
func _ready():
	label.text = key
	inventory = get_parent()
	for child in get_children():
		if is_instance_of(child, Tile):
			tile = child
			break

#
#func _can_drop_data(at_position, data) -> bool:
##	print("can drop data")
#	return data.is_in_group("Loot") and inventory.check_availble_for_place(slot_id, data)
#
#func _drop_data(at_position, data):
##	print("drop data")
#	inventory.handle_drop_placement(slot_id, data)
