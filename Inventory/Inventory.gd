extends Area2D

class_name Inventory

var inventory_slots = [
	[null, null, null], 
	[null, null, null]
];

var interactions = [
	[null, null, null],
	[null, null, null]	
]

# Called when the node enters the scene tree for the first time.
func _ready():	
	var slots = get_children()
	var slot_count = 0
	for slot in slots:
		if is_instance_of(slot, InventorySlot):
			slot.slot_id = slot_count
			slot.tile.set_item_type(null)
			inventory_slots[slot_count / 3][slot_count % 3] = slot
			slot_count += 1
			
#	# check inventory init
#	print("check inventory init")
#	for row in range(2):
#		for col in range(3):
#			print(inventory[row][col])

signal drop_area_clicked

func _input_event(viewport, event, shape_idx):
#	print("Inventory Gui Input")
	if event is InputEventMouseButton and event.is_action_pressed("LeftMouse"):
		print(event.position, self.transform.origin)
		drop_area_clicked.emit(self, event.position - self.transform.origin)

func check_availble_for_place(slot_id: int, tile_group: TileGroup) -> bool:
	print(slot_id, " ",tile_group)
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
			var tile = tile_group.tiles[row * 2 + col]
			if tile_type != null:				
				# change slot appearance
				var slot: InventorySlot = inventory_slots[slot_row + row][slot_col + col]
				slot.tile.set_item_type(tile_type)
				slot.tile.set_item_rotation(tile.rotation_degrees)
	update_keyboard_interactions()

func update_keyboard_interactions():
	for row in range(2):
		for col in range(3):
			var slot_id = row * 3 + col
			var slot: InventorySlot = inventory_slots[row][col]
			var tile: Tile = slot.tile
			var tile_type = tile.item_type
			# find other slot
			var other_slot
			match tile_type:
				Globals.SWORD_UP, Globals.WAND_UP:
					other_slot = get_slot_by_direction(slot_id, tile.rotation_degrees + 180)
				Globals.SWORD_DOWN, Globals.WAND_DOWN:
					other_slot = get_slot_by_direction(slot_id, tile.rotation_degrees)
				Globals.ARROW:
					interactions[row][col] = check_arrow_interaction(tile.rotation_degrees)
				Globals.KNIFE:
					interactions[row][col] = Globals.ATTACK_KNIFE
				Globals.POTION:
					interactions[row][col] = Globals.DRINK_POTION
				Globals.KEY:
					interactions[row][col] = Globals.USE_KEY
				Globals.SHIELD:
					interactions[row][col] = Globals.DEFEND_SHIELD
				_:
					continue
			
			if other_slot == null:
				continue
			
#			print("update interactions: ", other_slot)
			
			# update interaction
			match tile_type:
				Globals.SWORD_UP:
					interactions[row][col] = check_interaction(
						slot,
						Globals.SWORD_DOWN, 
						other_slot, 
						Globals.ATTACK_SWORD, 
						Globals.ATTACK_BROKEN_SWORD)
				Globals.SWORD_DOWN:
					interactions[row][col] = check_interaction(
						slot,
						Globals.SWORD_UP, 
						other_slot, 
						Globals.ATTACK_SWORD, 
						Globals.ATTACK_BROKEN_SWORD)
				Globals.WAND_UP:
					interactions[row][col] = check_interaction(
						slot,
						Globals.WAND_DOWN, 
						other_slot, 
						Globals.ATTACK_WAND, 
						Globals.ATTACK_BROKEN_WAND)
				Globals.WAND_DOWN:
					interactions[row][col] = check_interaction(
						slot,
						Globals.WAND_UP, 
						other_slot, 
						Globals.ATTACK_WAND, 
						Globals.ATTACK_BROKEN_WAND)
	
	# check update
	for row in range(2):
		for col in range(3):
			print(interactions[row][col])
	
	pass
	
func get_slot_by_direction(slot_id, direction: int) -> InventorySlot:
	var dir = (direction % 360 + 360) % 360
#	print("id:", slot_id, "\tdir: ", dir)	
	var row = slot_id / 3
	var col = slot_id % 3
	match dir / 90:
		1:
			col += 1
		2:
			row += 1
		3:
			col -= 1
		_:
			row -= 1
	
#	print("other slot_id: ", row * 3 + col)
	if col < 0 || col >= 3 || row < 0 || row >= 2:
		return null
	else:
		return inventory_slots[row][col]

func check_interaction(this_slot, other_type, other_slot, mode, broken_mode) -> int:
	if other_slot.tile.item_type == other_type:
#		print("this degrees: ", this_slot.tile.rotation_degrees, "\tother degrees: ", other_slot.tile.rotation_degrees)
		if this_slot.tile.rotation_degrees == other_slot.tile.rotation_degrees:
			return mode
	return broken_mode
	
func check_arrow_interaction(direction: int) -> int:
	var dir = (direction % 360 + 360) % 360
	match dir / 90:
		1:
			return Globals.MOVE_RIGHT
		2:
			return Globals.MOVE_BACK
		3:
			return Globals.MOVE_LEFT
		_:
			return Globals.MOVE_FORWARD
