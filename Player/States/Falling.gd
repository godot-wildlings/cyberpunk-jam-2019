extends Node2D

var fall_velocity : Vector2 = Vector2.ZERO
var player : KinematicBody2D
var my_state_num : int

func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.falling

func activate(arguments : Array = []):
	print(self.name, " arguments == ", arguments)
	var initial_velocity : Vector2 = Vector2.ZERO
	if arguments.size() > 0:
		initial_velocity = arguments[0]
	fall_velocity = initial_velocity
	player.animation_player.play("fall")
	$FallingSprite.show()

func deactivate():
	player.animation_player.stop()
	fall_velocity = Vector2.ZERO
	$FallingSprite.hide()

func process_state(delta):
	if player.state == my_state_num:
		fall_velocity.y += Game.gravity * delta
		#warning-ignore:return_value_discarded
		player.move_and_collide(fall_velocity * delta)
		if player.is_on_platform() == true:
			player.land(fall_velocity)
