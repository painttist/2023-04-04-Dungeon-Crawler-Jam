extends Panel

class_name Inventory

var inventory_slots = [
	[null, null, null], 
	[null, null, null]
];

# Called when the node enters the scene tree for the first time.
func _ready():
	var children = get_children()
	var grid;
	for child in children:
		if child is GridContainer:
			grid = child
			break
	
	var slots = grid.get_children()
	var slot_count = 0
	for slot in slots:
		if is_instance_of(slot, InventorySlot):
			slot.slot_id = slot_count
			inventory_slots[slot_count / 3][slot_count % 3] = slot
			slot_count += 1
			
#	# check inventory init
#	print("check inventory init")
#	for row in range(2):
#		for col in range(3):
#			print(inventory[row][col])

func check_availble_for_place(slot_id: int, tile_group: TileGroup) -> bool:
	print("check")
	
	return true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
