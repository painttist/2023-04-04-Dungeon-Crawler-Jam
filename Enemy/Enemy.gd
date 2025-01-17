extends StaticBody3D

class_name Enemy

@onready var player : Player = get_parent().get_node("Player")

@onready var level : GridMap = get_parent().get_node("level")

@onready var animation = $AnimationPlayer
@onready var audio = $AudioStreamPlayer3D

var sfx_slime_jump = preload("res://Audio/slime_jump.mp3")
var sfx_slime_attack = preload("res://Audio/slime_attack.wav")

var sfx_wolf_walk = preload("res://Audio/WHOOSH_Air_Super_Fast_RR5_mono.wav")
var sfx_wolf_attack = preload("res://Audio/WHOOSH_Air_Super_Fast_RR4_mono.wav")

enum ENEMY_TYPE {
	SLIME,
	WOLF
}

@export var type :ENEMY_TYPE
@export var damage: int = 1
@export var attack_cd: int = 2

var attack_cd_counter = 0

var reward

const TWEEN_DURATION = 0.3
const ROTATION_SPEED = 8.0

const MAX_DISTANCE = 6.0

const MIN_MOVE_DISTANCE = 2.2

var tween : Tween

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

@export var health = 2

func take_damage(attacker: Player, damage):
	health -= damage
#	attacker.move_back()
	print("enemy health: ", health, " attacked by ", attacker.name)
	if health <= 0:
		animation.play("take_damage")
		await animation.animation_finished
		attacker.get_reward(reward)
#		await animation.animation_finished
		self.queue_free()
	else:
		animation.play("take_damage")
		
const FLOAT_EPSILON = 0.00001

func get_intersect_to_player() -> Dictionary:
	var space_state = get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = self.transform.origin
	params.to = player.transform.origin
	params.exclude = [self.get_rid()]
	params.collision_mask = 1
	return space_state.intersect_ray(params)

func no_intersect_to_dir(dir: Vector3):
	var space_state = get_world_3d().get_direct_space_state()
	var params = PhysicsRayQueryParameters3D.new()
	params.from = self.transform.origin
	params.to = self.transform.translated(dir * 2.5).origin
	params.exclude = [self.get_rid()]
	params.collision_mask = 1
	return space_state.intersect_ray(params).is_empty()

func attack():
	if animation.is_playing():
		await animation.animation_finished
	attack_cd_counter += 1
	if attack_cd_counter >= attack_cd:
		attack_cd_counter = 0
		match type:
			self.ENEMY_TYPE.SLIME:
				audio.stream = sfx_slime_attack
				audio.play()
				animation.play("attack")
			self.ENEMY_TYPE.WOLF:
				audio.stream = sfx_wolf_attack
				audio.play()
				animation.play("attack_strike")
		await animation.animation_finished
		player.take_damage(damage)

func move_towards_player():
	if health <= 0:
		return
	var dist = get_dist_to_player()
	if (dist <= MIN_MOVE_DISTANCE):
		attack()
		return
	
	if (get_intersect_to_player() and dist >= MAX_DISTANCE) :
		return
#	print("Moving towards player")
#	print(dist)
#	var cell = level.get_cell_item(self.transform.origin)
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
	var moving = false
	if dir.x > FLOAT_EPSILON and cell_r >= 0 and no_intersect_to_dir(Vector3.RIGHT):
#		print("move right")
		moving = true
		move_right()
	elif dir.x < -FLOAT_EPSILON and cell_l >= 0 and no_intersect_to_dir(Vector3.LEFT):
#		print("move left")
		moving = true
		move_left()
	elif dir.z < -FLOAT_EPSILON and cell_f >= 0 and no_intersect_to_dir(Vector3.FORWARD):
#		print("move front")
		moving = true
		move_forward()
	elif dir.z > FLOAT_EPSILON and cell_b >= 0 and no_intersect_to_dir(Vector3.BACK):
#		print("move back")
		moving = true
		move_back()
#		move_forward()
	if (moving):
		print(self.name, " Moving") 
		if (audio is AudioStreamPlayer3D):
			match type:
				self.ENEMY_TYPE.SLIME:
					audio.stream = sfx_slime_jump
					audio.play()
				self.ENEMY_TYPE.WOLF:
					audio.stream = sfx_wolf_walk
					audio.volume_db = -8
					audio.max_db = -2
					audio.play()
					await audio.finished
					audio.volume_db = 0
					audio.max_db = 3
		await tween.finished
		print(self.name, " Finished Moving")
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

func add_enemy_action():
	if health > 0:
		Globals.enemy_add_action(move_towards_player)

func _ready():
	if player is Player:
		player.acted.connect(add_enemy_action)

	if type == ENEMY_TYPE.WOLF:
		reward = Globals.get_rand_wolf_loot()
	elif type == ENEMY_TYPE.SLIME:
		reward = Globals.get_rand_slime_loot()
	print(reward)
