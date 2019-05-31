extends Player_State

#var player : KinematicBody2D
var run_velocity: Vector2 = Vector2.ZERO
var my_state_num : int
var sprite : Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.running
	sprite = $RunningSprite
	sprite.hide()

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

		if Input.is_action_just_pressed("mv_down"):
			player.crouch(run_velocity)
			return

		var damping = 0.1
		var new_vel = move_and_bounce(run_velocity, delta, damping)
		velocity = new_vel # important to update this every frame, even if we don't use it.

#func flip_sprites(dir):
#	if dir > 0:
#		sprite.set_flip_h(false)
#	else:
#		sprite.set_flip_h(true)


func activate(arguments : Array = []):

	#sprite.show()
	#sprite.set_modulate(Color.white)
	player.animation_player.play("run")

func deactivate():
	player.animation_player.stop()
	get_node("RunningSprite").hide()
	run_velocity = Vector2.ZERO




