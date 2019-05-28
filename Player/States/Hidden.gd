extends Player_State

#var player : KinematicBody2D
var my_state_num : int

func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.hidden

#warning-ignore:unused_argument
func activate(arguments : Array = []):
	player.hide()

func deactivate():
	player.show()

#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		if Input.is_action_just_pressed("mv_down"):
			player.exit()