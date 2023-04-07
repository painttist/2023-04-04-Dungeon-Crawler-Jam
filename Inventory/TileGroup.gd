extends GridContainer

class_name TileGroup

var group = [
	[null, null],
	[null, null]
]

var follow_cursor = false

var tiles: Array[Tile]
#var is_dragging: bool = false
#var drag_offset: Vector2
#var original_pos: Vector2
const drag_preview = preload("res://Inventory/TileGroupPreview.tscn")

func init():
	var children = get_children()
	for child in children:
		if child is Tile:
			tiles.append(child)
	group = Globals.get_rand_tile_set()
	update_tiles()

# Called when the node enters the scene tree for the first time.
func _ready():
	init()
	add_to_group("Loot")

#func _process(delta):
##	print(get_viewport().get_mouse_position())
#	if is_dragging:
#		position = get_viewport().get_mouse_position() - drag_offset

func rotate_left():
	var new_group = [
		[group[0][1], group[1][1]],
		[group[0][0], group[1][0]]
	]
	group = new_group
	merge_null_in_group()
	update_tiles()
	for tile in tiles:
		tile.rotate_left()

	
func rotate_right():
	var new_group = [
		[group[1][0], group[0][0]],
		[group[1][1], group[0][1]]
	]
	group = new_group
	merge_null_in_group()
	update_tiles()	
	for tile in tiles:
		tile.rotate_right()
		
func merge_null_in_group():
	if group[0][0] == null and group[0][1] == null:
		group[0][0] = group[1][0]
		group[0][1] = group[1][1]
		group[1][0] = null
		group[1][1] = null
	elif group[0][0] == null and group[1][0] == null:
		group[0][0] = group[0][1]
		group[1][0] = group[1][1]
		group[0][1] = null
		group[1][1] = null	
	
func update_tiles():
	# update tiles
	var tile_counter = 0
	for row in range(2):
		for col in range(2):
#			print(group[row][col])
			tiles[tile_counter].set_item_type(group[row][col])
			tile_counter += 1

func _input(event):
	if event.is_action_pressed("A"):
		rotate_left()
	elif event.is_action_pressed("D"):
		rotate_right()

# _input -> _gui_input -> _unhandled_input
func _gui_input(event: InputEvent):
	print("Tile Group GUI Input")
	if event is InputEventMouseButton:
		if (event.is_action_pressed("LeftMouse")):
			if is_valid_position(event.position):
				print("Is valid, can pickup: ", event.position)
				follow_cursor = true
				self.mouse_filter = Control.MOUSE_FILTER_IGNORE

#func _unhandled_input(event):
#	if event.is_action_pressed("LeftMouse"):
#		if follow_cursor:
#			follow_cursor = false
#			self.mouse_filter = Control.MOUSE_FILTER_PASS
#			if event is InputEventMouseButton:
#				print("Stop follow: ", event.position)


func _process(delta):
	if follow_cursor:
		var mouse_pos = get_global_mouse_position()
#		print("mouse: ", mouse_pos)
		self.position = mouse_pos - Vector2(20, 20)

func _get_drag_data(at_position: Vector2): 
	print("get drag data: ", at_position)
	if is_valid_position(at_position):
		var preview = drag_preview.instantiate()
		preview.drag_offset = at_position
		get_tree().get_root().get_node("World/UI").add_child(preview) # Hardcode
#		set_drag_preview(preview) # Built-in preview is bad
		return self
	
#func on_tile_group_drag(event: InputEvent):
##	print(event)
#	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
#		# init dragging
#		if !is_dragging and is_valid_position(event.position):
#			is_dragging = true
#			# event.position is dragging offset
#			drag_offset = event.position
#			original_pos = self.global_position 
#		elif is_dragging:
#			is_dragging = false
#			if is_hitting_inventory(event.position):
#				print("release")
#			else:
#				position = original_pos # add animation
#				print("place back")
		

func is_valid_position(pos: Vector2) -> bool:
#	print(pos)
	var row = int(pos.y) / 100	# HardCode: size of one tile
	var col = int(pos.x) / 100
	return group[row][col] != null
#
#func is_hitting_inventory(pos: Vector2) -> bool:
#	return Globals.is_mouse_inside_inventory


func _on_inventory_drop_area_clicked():
	print("drop")
	if follow_cursor:
		follow_cursor = false
		self.mouse_filter = Control.MOUSE_FILTER_PASS
