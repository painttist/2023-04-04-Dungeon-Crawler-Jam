extends StaticBody3D

@onready var player = get_parent().get_node("Player")

#func _physics_process(delta):
#	look_at(player.position)

var health = 10

@onready var light = $OmniLight3D
@onready var animation = $AnimationPlayer
@onready var audio = $AudioStreamPlayer3D
@onready var audio_hit = $AudioStreamPlayer3D2

func take_damage(attacker : Player, damage):
	health -= damage
	print("chest health: ", health)
	if health <= 0:
		audio.play()
		animation.play("chest_open")
		await animation.animation_finished
		attacker.get_reward()
		self.queue_free()
		return
	else:
		audio_hit.play()
		animation.play("take_damage")
	light.light_energy = float(health) / 10.0


	
