extends Node3D

class_name Player

const TWEEN_DURATION = 0.3

@onready var ray_front = $RayFront
@onready var ray_back = $RayBack
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight

@onready var animation = $AnimationPlayer

var tween

signal acted

func move_forward() -> void:
	if not ray_front.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.FORWARD * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_bob")
	else:
		print_debug("touching ", ray_front.get_collider().name)

func move_back() -> void:
	if not ray_back.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.BACK * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_bob")

func move_left() -> void:
	if not ray_left.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.LEFT * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_tilt_left")

func move_right() -> void:
	if not ray_right.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.RIGHT * 2), TWEEN_DURATION)
		tween.tween_callback(func(): acted.emit())
		animation.play("head_tilt_right")

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
			col.take_damage(self, 2)
	acted.emit()

func _physics_process(_delta):
	if tween is Tween:
		if tween.is_running():
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
	elif Input.is_action_pressed("Q"):
		turn_left()
	elif Input.is_action_pressed("E"):
		turn_right()
	
