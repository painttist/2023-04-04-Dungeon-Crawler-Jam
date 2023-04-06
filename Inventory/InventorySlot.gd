extends TextureRect

class_name InventorySlot

var inventory: Inventory
var slot_id

# Called when the node enters the scene tree for the first time.
func _ready():
	inventory = get_parent().get_parent()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _can_drop_data(at_position, data) -> bool:
#	print("can drop data")
	return inventory.check_availble_for_place(slot_id, null)

func _drop_data(at_position, data):
	print("drop data")
	pass
