extends Player_State

#var player : KinematicBody2D
var my_state_num : int

var warning_issued: bool = false

var sprite : Sprite

enum states { ready, climbing }
var state = states.ready

var initial_platform

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.climbing
	sprite = $ClimbingSprite
	sprite.hide()




#warning-ignore:unused_argument
func activate(arguments : Array = []):
	state = states.ready
	initial_platform = player.get_current_platform()
	if arguments.size() > 0:
		#sprite.show()
		#player.play_random_climb_sfx()
		Game.play_random_sfx($SFX)
		move_to_platform(arguments[0])
	else:
		player.jump(Vector2.ZERO)

func deactivate():
	state = states.ready
	sprite.hide()



func flip_sprites(dir):
	pass
#	if player.get_direction() > 0:
#		sprite.set_flip_h(false)
#	else:
#		sprite.set_flip_h(true)

func move_to_platform(platform):

	state = states.climbing
	player.animation_player.play("climb")

func process_state(delta):
	if player.state == my_state_num and state == states.climbing:
		var speed = 300.0
		velocity = Vector2.UP * speed
		var damping = 0.2
		velocity = move_and_bounce(velocity, delta, damping)

		if player.is_on_platform():
			if player.get_current_platform() != initial_platform:
				player.stop(velocity)
