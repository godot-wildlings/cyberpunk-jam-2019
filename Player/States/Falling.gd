extends Player_State

var fall_velocity : Vector2 = Vector2.ZERO
#var player : KinematicBody2D
var my_state_num : int
onready var sprite : Sprite = $FallingSprite

var ticks : int = 0

func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.falling

#warning-ignore:unused_arguments
func activate(arguments : Array = []):

	var initial_velocity : Vector2 = Vector2.ZERO
	if arguments.size() > 0:
		initial_velocity = arguments[0]
	fall_velocity = initial_velocity

	player.animation_player.play("fall")
	#sprite.show()
	sprite.hide()

func deactivate():
	player.animation_player.stop()
	#fall_velocity = Vector2.ZERO
	sprite.hide()

func process_state(delta):
	ticks += 1

	if player.state == my_state_num:

		fall_velocity.y += Game.gravity * delta

		var damping = 0.1
		var new_vel = move_and_bounce(fall_velocity, delta, damping)
		fall_velocity = new_vel
		velocity = fall_velocity

		if player.is_on_platform() == true:
			#velocity.y = 0
			player.land(new_vel)


#func flip_sprites(dir):
#	if dir > 0:
#		sprite.set_flip_h(false)
#	else:
#		sprite.set_flip_h(true)
