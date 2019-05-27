"""
Ask the level to display blue lines and turn the static-body sprites grey

"""

extends Node2D

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	#warning-ignore:return_value_discarded
	$DurationTimer.connect("timeout", self, "_on_DurationTimer_timeout")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use():
	#var candidates = Game.main.level.get_static_bodies()
	player.iReal_active = true
	$DurationTimer.start()

func _on_DurationTimer_timeout():
	player.iReal_active = false
