extends Player_State

#var player : KinematicBody2D
var my_state_num : int

var warning_issued: bool = false

var sprite : Sprite

enum states { ready, jumping, moving, landing }
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
	# need to tween this or something
	var my_pos = player.get_global_position()
	assert(platform.get_child(0) is CollisionShape2D)
	var platform_floor = platform.get_global_position().y - platform.get_child(0).get_shape().get_extents().y

	var new_position = Vector2(my_pos.x, platform_floor - player.character_height/2)
	player.tween.interpolate_property(player, "position",
		player.position, new_position, 0.6,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	player.tween.start()


	if not warning_issued:
		push_warning(self.name + ": yielding for movement probably isn't the best approach")
		warning_issued = true
	yield(player.tween, "tween_completed")
	player.stop(Vector2.ZERO)


func process_state(delta):
	if player.state != my_state_num:
		return

	if state == states.ready:
		state = states.moving
		player.animation_player.set_current_animation("climb")
		player.animation_player.seek(0)
		player.animation_player.play("climb")

	elif state == states.moving:
		var speed = 300.0
		velocity = Vector2.UP * speed
		var damping = 0.2
		velocity = move_and_bounce(velocity, delta, damping)

		if player.is_on_platform():
			if player.get_current_platform() != initial_platform:
				player.stop(velocity)
