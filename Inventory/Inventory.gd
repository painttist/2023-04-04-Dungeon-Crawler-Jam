extends PanelContainer

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

signal drop_area_clicked

func _gui_input(event):
#	print("Inventory Gui Input")
	if event is InputEventMouseButton and event.is_action_pressed("LeftMouse"):
		drop_area_clicked.emit(self, event.position)

func check_availble_for_place(slot_id: int, tile_group: TileGroup) -> bool:
#	print(slot_id, " ",tile_group)
	if slot_id == 0 or slot_id == 1:
		return true
	elif slot_id == 2:
		return tile_group.group[0][1] == null and tile_group.group[1][1] == null
	elif slot_id == 3 or slot_id == 4:
		return tile_group.group[1][0] == null and tile_group.group[1][1] == null
	else:
		return false

func handle_drop_placement(slot_id: int, tile_group: TileGroup):
	var slot_row = slot_id / 3
	var slot_col = slot_id % 3
	for row in range(2):
		for col in range(2):
			var tile_type = tile_group.group[row][col]
			var tile = tile_group.tiles[slot_id]
			if tile_type != null:
				var slot: InventorySlot = inventory_slots[slot_row + row][slot_col + col]
				slot.tile.set_item_type(tile_type)
				slot.tile.set_item_rotation(tile.item_rotation)
