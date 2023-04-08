extends Node3D

class_name Player

const TWEEN_DURATION = 0.3

@onready var ray_front = $RayFront
@onready var ray_back = $RayBack
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight

@onready var animation = $AnimationPlayer

@onready var ui: SkillUI = $SkillUI

@onready var audio = $AudioStreamPlayer3D

var sfx_player_attack = preload("res://Audio/WHOOSH_Air_Very_Fast_RR2_mono.wav")
var sfx_player_walk = preload("res://Audio/IMPACT_Stone_Deep_mono.wav")
var sfx_reward = preload("res://Audio/PUZZLE_Success_Xylophone_2_Two_Note_Climb_Bright_Delay_stereo.wav")

var is_picking_skills = false
var inventory: Inventory

var tween

var health = 10

signal acted

signal health_changed


func play_walk_audio():
	audio.stream = sfx_player_walk
	audio.play()	

func check_pickup(collided: Node3D) -> bool:
	if collided.has_method("picked_up"):
#		print("Can pickup")
		collided.picked_up(self)
		return true
	return false

func move_forward() -> void:
	var will_move = false
	if not ray_front.is_colliding():
		will_move = true
	else:
		var collided : Node3D = ray_front.get_collider()
		will_move = check_pickup(collided)
	
	if will_move:
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.FORWARD * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_bob")
		play_walk_audio()
	else:
		animation.play("head_bob")
#		print_debug("touching ", ray_front.get_collider().name)

func move_back() -> void:
	var will_move = false
	if not ray_back.is_colliding():
		will_move = true
	else:
		var collided : Node3D = ray_back.get_collider()
		will_move = check_pickup(collided)
	
	if will_move:
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.BACK * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_bob")
		play_walk_audio()
	else:
		animation.play("head_bob")

func move_left() -> void:
	var will_move = false
	if not ray_left.is_colliding():
		will_move = true
	else:
		var collided : Node3D = ray_left.get_collider()
		will_move = check_pickup(collided)
		
	if will_move:
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.LEFT * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_tilt_left")
		play_walk_audio()
	else:
		animation.play("head_bob")

func move_right() -> void:
	var will_move = false
	if not ray_right.is_colliding():
		will_move = true
	else:
		var collided : Node3D = ray_right.get_collider()
		will_move = check_pickup(collided)
		
	if will_move:
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.RIGHT * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_tilt_right")
		play_walk_audio()
	else:
		animation.play("head_bob")

func turn_right() -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, -PI/2), TWEEN_DURATION)

func turn_left() -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, PI/2), TWEEN_DURATION)

func attack() -> void:
	if ray_front.is_colliding():
		var col = ray_front.get_collider()
		if col.has_method("take_damage"):
			if col.health > 0:
				audio.stream = sfx_player_attack
				audio.play()
				animation.play("attack")
				await animation.animation_finished
				col.take_damage(self, 2)
	acted.emit()

func take_damage(amount):
	health -= amount
	health_changed.emit(health)
	animation.play("take_damage") # special animation that has 0.3s for receiving attack anim and 0.3s for hit anim
	print("Player health: ", health)
	if health <= 0:
		await animation.animation_finished
		get_tree().reload_current_scene()

func get_reward(reward):
	audio.stream = sfx_reward
	audio.play()
	is_picking_skills = true
	ui.visible = is_picking_skills
	ui.update_reward(reward)

#func _unhandled_input(event):
#	if event.is_action_pressed("LeftMouse"):
#		is_picking_skills = !is_picking_skills
#		ui.visible = is_picking_skills

func _ready():
	ui.visible = is_picking_skills
	inventory = find_child("Inventory")
#	print(inventory)

func _physics_process(_delta):
	
	if is_picking_skills : return
	
	if tween is Tween:
		if tween.is_running():
			return
	if animation.is_playing():
		return
	
	var check_input = false
	var row
	var col
	if Input.is_action_pressed("Q"):
		row = 0
		col = 0
	elif Input.is_action_pressed("W"):
		row = 0
		col = 1
	elif Input.is_action_pressed("E"):
		row = 0
		col = 2
	elif Input.is_action_pressed("A"):
		row = 1
		col = 0
	elif Input.is_action_pressed("S"):
		row = 1
		col = 1
	elif Input.is_action_pressed("D"):
		row = 1
		col = 2
	else:
		return
	
	if inventory.interactions[row][col] != null:
		handle_behaviour(inventory.interactions[row][col])
	
func handle_behaviour(behaviour: int):
	if not (behaviour == Globals.TURN_LEFT || behaviour == Globals.TURN_RIGHT):
		if not Globals.player_ready():
			print("Player is not ready")
			return
		
	match behaviour:
		Globals.MOVE_FORWARD:
			move_forward()
		Globals.MOVE_BACK:
			move_back()
		Globals.MOVE_LEFT:
			move_left()
		Globals.MOVE_RIGHT:
			move_right()
		Globals.TURN_LEFT:
			turn_left()
		Globals.TURN_RIGHT:
			turn_right()
		_:
			attack()
