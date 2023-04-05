extends Node3D

const TWEEN_DURATION = 0.3

@onready var ray_front = $RayFront
@onready var ray_back = $RayBack
@onready var ray_left = $RayLeft
@onready var ray_right = $RayRight

@onready var animation = $AnimationPlayer

var tween 

func _physics_process(delta):
	if tween is Tween:
		if tween.is_running():
			return
	if Input.is_action_pressed("forward") and not ray_front.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.FORWARD * 2), TWEEN_DURATION)
		animation.play("head_bob")
	if Input.is_action_pressed("backward") and not ray_back.is_colliding():
		tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "transform", transform.translated_local(Vector3.BACK * 2), TWEEN_DURATION)
		animation.play("head_bob")
	if Input.is_action_pressed("turn-left"):
		tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, PI/2), TWEEN_DURATION)
	if Input.is_action_pressed("turn-right"):
		tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "transform", transform.rotated_local(Vector3.UP, -PI/2), TWEEN_DURATION)
 
