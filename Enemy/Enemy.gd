extends StaticBody3D

@onready var player : Player = get_parent().get_node("Player")

@onready var ray_front = $RayFront
@onready var ray_back = $RayBack
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight

@onready var level : GridMap = get_parent().get_node("level")

const TWEEN_DURATION = 0.3
const ROTATION_SPEED = 8.0

const MAX_DISTANCE = 6.0

const MIN_MOVE_DISTANCE = 2.2

var tween

func move_forward() -> void:
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.FORWARD * 2), TWEEN_DURATION)

func move_back() -> void:
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.BACK * 2), TWEEN_DURATION)

func move_left() -> void:
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.LEFT * 2), TWEEN_DURATION)

func move_right() -> void:	
	tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "transform", transform.translated(Vector3.RIGHT * 2), TWEEN_DURATION)

func get_dist_to_player() -> float:
	return self.transform.origin.distance_to(player.transform.origin)

func look_at_player_smooth(delta):
	var current_rot = transform.basis.get_rotation_quaternion().normalized()
	var look_at_rot = transform.looking_at(player.position).basis.get_rotation_quaternion().normalized()
	
	transform.basis = Basis(current_rot.slerp(look_at_rot, delta * ROTATION_SPEED))
	
func _physics_process(delta):
	if not player is Player:
		return
	if get_intersect_to_player().is_empty():
		look_at_player_smooth(delta)

var health = 6

func take_damage(attacker, damage):
	health -= damage
#	attacker.move_back()
	print("enemy health: ", health, " attacked by ", attacker.name)
	check_death()

func check_death():
	if health <= 0:
		self.queue_free()
		
const FLOAT_EPSILON = 0.00001

func get_intersect_to_player() -> Dictionary:
	var space_state = get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = self.transform.origin
	params.to = player.transform.origin
	params.exclude = [self.get_rid()]
	params.collision_mask = 1
	return space_state.intersect_ray(params)

func move_towards_player():
	var dist = get_dist_to_player()
	if (dist <= MIN_MOVE_DISTANCE):
		player.take_damage(2)
		return
	
	if (get_intersect_to_player() and dist >= MAX_DISTANCE) :
		return
#	print("Moving towards player")
#	print(dist)
	var cell = level.get_cell_item(self.transform.origin)
	var cell_f = level.get_cell_item(self.transform.translated(Vector3.FORWARD * 2).origin)
	var cell_b = level.get_cell_item(self.transform.translated(Vector3.BACK * 2).origin)
	var cell_l = level.get_cell_item(self.transform.translated(Vector3.LEFT * 2).origin)
	var cell_r = level.get_cell_item(self.transform.translated(Vector3.RIGHT * 2).origin)
#	print(cell)
#	print(cell_f)
#	print(cell_b)
#	print(cell_l)
#	print(cell_r)
	
#	var dir = self.transform.basis.looking_at(player.transform.origin)
	var dir = self.transform.origin.direction_to(player.transform.origin)
	if dir.x > FLOAT_EPSILON and cell_r >= 0:
#		print("move right")
		move_right()
	elif dir.x < -FLOAT_EPSILON and cell_l >= 0:
#		print("move left")
		move_left()
	elif dir.z < -FLOAT_EPSILON and cell_f >= 0:
#		print("move front")
		move_forward()
	elif dir.z > FLOAT_EPSILON and cell_b >= 0:
#		print("move back")
		move_back()
#		move_forward()
#	print("dir: ", dir)
#	print("dist: ", dist)
#	print("basis: ", self.transform.basis)
	
#	if (abs(dir.x) > abs(dir.z)):
##		move left or right
#		if dir.x > 0:
#			move_right()
#		else:
#			move_left()
#	else:
##		move foward or back
#		if dir.z > 0:
#			print("move back")
#			move_back()
#		else:
#			print("move foward")
#			move_forward()
	
func _ready():
	if player is Player:
		print(player.name)
		player.acted.connect(move_towards_player)
