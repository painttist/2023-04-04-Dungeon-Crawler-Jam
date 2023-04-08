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
var sfx_potion = preload("res://Audio/drink.mp3")
var sfx_shield = preload("res://Audio/shield.mp3")
var sfx_equip = preload("res://Audio/equip.mp3")

var is_picking_skills = false
var inventory: Inventory

var tween

var health = 10
var is_defending = false

signal acted

signal health_changed
signal defend_changed

func play_walk_audio():
	audio.stream = sfx_player_walk
	audio.play()	

func check_pickup(collided: Node3D) -> bool:
	if collided.has_method("picked_up"):
#		print("Can pickup")
		collided.picked_up(self)
		return true
	return false
	
func drink_potion():
	audio.stream = sfx_potion
	audio.play(0.1)
	print("player drink potion")
	health += 3
	health_changed.emit(health)

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
		reset_defend()
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
		reset_defend()
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
		reset_defend()
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
		reset_defend()
	else:
		animation.play("head_bob")

func turn_right() -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, -PI/2), TWEEN_DURATION)

func turn_left() -> void:
	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, PI/2), TWEEN_DURATION)

func defend() -> void:
	audio.stream = sfx_equip
	audio.play()
	animation.play("head_tilt_left")
	is_defending = true
	defend_changed.emit(is_defending)
	await animation.animation_finished
	acted.emit()

func reset_defend() :
	is_defending = false
	defend_changed.emit(is_defending)

func attack(player_damage: int) -> void:
	if ray_front.is_colliding():
		var col = ray_front.get_collider()
		if col.has_method("take_damage"):
			if col.health > 0:
				audio.stream = sfx_player_attack
				audio.play()
				animation.play("attack")
				await animation.animation_finished
				col.take_damage(self, player_damage)
	reset_defend()
	acted.emit()

func take_damage(amount):
	if (is_defending):
		audio.stream = sfx_shield
		audio.play()
		reset_defend()
		print("Defended")
		return
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

func on_button_close_skill_ui():
	ui.visible = false
	is_picking_skills = false

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
	if Input.is_action_just_pressed("Q"):
		row = 0
		col = 0
	elif Input.is_action_just_pressed("W"):
		row = 0
		col = 1
	elif Input.is_action_just_pressed("E"):
		row = 0
		col = 2
	elif Input.is_action_just_pressed("A"):
		row = 1
		col = 0
	elif Input.is_action_just_pressed("S"):
		row = 1
		col = 1
	elif Input.is_action_just_pressed("D"):
		row = 1
		col = 2
	else:
		return
	
	if inventory.interactions[row][col] != null:
		handle_behaviour(inventory.interactions[row][col])		
		inventory.consume_durality(row, col)
	else:
		acted.emit()
	
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
		Globals.DRINK_POTION:
			drink_potion()
		Globals.ATTACK_KNIFE:
			attack(1)
		Globals.ATTACK_SWORD:
			attack(3)
		Globals.ATTACK_BROKEN_SWORD:
			attack(2)
		Globals.ATTACK_WAND:
			attack(5)
		Globals.ATTACK_BROKEN_WAND:
			attack(1)
		Globals.DEFEND_SHIELD:
			defend()
		_:
			attack(1)

func restart_game():
	get_tree().reload_current_scene()
	Globals.enemy_actions_stack = []
	Globals.enemy_action_running = false
