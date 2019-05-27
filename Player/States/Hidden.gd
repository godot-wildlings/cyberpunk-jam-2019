extends Node2D


var player : KinematicBody2D
var my_state_num : int

func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.hidden

func activate(arguments : Array = []):
	player.hide()

func deactivate():
	player.show()

func process_state(delta):
	if player.state == my_state_num:
		if Input.is_action_just_pressed("mv_down"):
			player.exit()