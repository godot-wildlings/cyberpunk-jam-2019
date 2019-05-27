extends Node2D

var player : KinematicBody2D
var run_velocity: Vector2 = Vector2.ZERO
var my_state_num : int


# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.running

#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		if player.is_on_platform() == false:
			player.fall(run_velocity)
			return

		if Input.is_action_pressed("mv_right"):
			run_velocity = Vector2.RIGHT * player.speed
		elif Input.is_action_pressed("mv_left"):
			run_velocity = Vector2.LEFT * player.speed
		else:
			player.stop(run_velocity)
			return

		if Input.is_action_just_pressed("jump") or Input.is_action_just_pressed("mv_up"):
			player.jump(run_velocity)
			return

		#warning-ignore:return_value_discarded
		player.move_and_collide(run_velocity * delta)



func activate(arguments : Array = []):

	get_node("RunningSprite").show()
	$RunningSprite.set_modulate(Color.white)
	player.animation_player.play("run")

func deactivate():
	player.animation_player.stop()
	get_node("RunningSprite").hide()
	run_velocity = Vector2.ZERO




