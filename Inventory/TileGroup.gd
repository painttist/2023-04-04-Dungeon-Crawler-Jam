extends GridContainer

class_name TileGroup

var group = [
	[null, null],
	[null, null]
]

var tiles: Array[Tile]
var is_dragging: bool = false
var drag_offset: Vector2
var original_pos: Vector2

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
#	add_to_group("Loot")

func _process(delta):
#	print(get_viewport().get_mouse_position())
	if is_dragging:
		position = get_viewport().get_mouse_position() - drag_offset

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
	
#func _get_drag_data(at_position: Vector2): 
#	print("get drag data: ", at_position)
#	var preview = TextureRect.new()
#	preview.texture = preload("res://Sprites/sword.png")
#	set_drag_preview(preview)
#	return self
	
func on_tile_group_drag(event: InputEvent):
#	print(event.as_text())
	print(event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# init dragging
		if !is_dragging and is_valid_position(event.position):
			is_dragging = true
			# event.position is dragging offset
			drag_offset = event.position
			original_pos = self.global_position 


func is_valid_position(pos: Vector2) -> bool:
#	print(pos)
	var row = int(pos.y) / 100	# HardCode: size of one tile
	var col = int(pos.x) / 100
	return group[row][col] != null

