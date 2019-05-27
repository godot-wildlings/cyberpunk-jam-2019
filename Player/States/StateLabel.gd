extends Label

var player : KinematicBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent()

#warning-ignore:unused_argument
func _process(delta):
	set_text(player.state_names[player.state])
