extends Node3D

class_name Player

const TWEEN_DURATION = 0.3

@onready var ray_front = $RayFront
@onready var ray_back = $RayBack
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight

@onready var animation = $AnimationPlayer

@onready var ui = $SkillUI

@onready var audio = $AudioStreamPlayer3D

@onready var sfx_player_attack = preload("res://Audio/WHOOSH_Air_Very_Fast_RR2_mono.wav")
@onready var sfx_player_walk = preload("res://Audio/IMPACT_Stone_Deep_mono.wav")

var is_picking_skills = false

var tween

var health = 10

signal acted

func play_walk_audio():
	audio.stream = sfx_player_walk
	audio.play()	

func move_forward() -> void:
	if not ray_front.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.FORWARD * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_bob")
		play_walk_audio()
	else:
		animation.play("head_bob")
#		print_debug("touching ", ray_front.get_collider().name)

func move_back() -> void:
	if not ray_back.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.BACK * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_bob")
		play_walk_audio()
	else:
		animation.play("head_bob")

func move_left() -> void:
	if not ray_left.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.LEFT * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_tilt_left")
		play_walk_audio()
	else:
		animation.play("head_bob")

func move_right() -> void:
	if not ray_right.is_colliding():
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
	animation.play("take_damage") # special animation that has 0.3s for receiving attack anim and 0.3s for hit anim
	print("Player health: ", health)

func _unhandled_input(event):
	if event.is_action_pressed("LeftMouse"):
		is_picking_skills = !is_picking_skills
		ui.visible = is_picking_skills

func _ready():
	ui.visible = is_picking_skills

func _physics_process(_delta):
	
	if is_picking_skills : return
	
	if tween is Tween:
		if tween.is_running():
			return
	if animation.is_playing():
		return
	
	if Input.is_action_pressed("Q"):
		turn_left()
		return
	elif Input.is_action_pressed("E"):
		turn_right()
		return
		
	if not Globals.player_ready():
#		print("Player is not ready")
		return
	
	if Input.is_action_just_pressed("Space"):
		attack()
	elif Input.is_action_pressed("W"):
		move_forward()
	elif Input.is_action_pressed("S"):
		move_back()
	elif Input.is_action_pressed("A"):
		move_left()
	elif Input.is_action_pressed("D"):
		move_right()
	
