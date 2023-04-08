extends Sprite2D

func _ready():
	self.visible = false

func _on_player_defend_changed(defend):
	self.visible = defend
