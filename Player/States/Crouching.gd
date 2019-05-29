extends Player_State

#var player : KinematicBody2D
var my_state_num
var sprite : Sprite
var fall_velocity : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.crouching
	sprite = $CrouchingSprite

#warning-ignore:unused_argument
func activate(arguments : Array = []):
	# might receive a velocity argument, but it's ignored
	$CrouchingSprite.show()
	var shape = player.get_node("CollisionShape2D").get_shape()
	var y_delta = shape.get_extents().y/2
	shape.set_extents(Vector2(shape.get_extents().x, shape.get_extents().y/2))

	#warning-ignore:return_value_discarded
	player.move_and_collide(Vector2.DOWN * y_delta)

func deactivate():
	$CrouchingSprite.hide()
	var shape = player.get_node("CollisionShape2D").get_shape()
	var y_delta = shape.get_extents().y/2
	shape.set_extents(Vector2(shape.get_extents().x, shape.get_extents().y*2))

	#warning-ignore:return_value_discarded
	player.move_and_collide(Vector2.UP * y_delta)
	player.animation_player.stop()

#warning-ignore:unused_argument
func process_state(delta):

	if player.state == my_state_num:

		var mv_velocity = Vector2.ZERO
		var crouching_mv_speed = player.speed / 3
		if Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
			mv_velocity = Vector2.RIGHT * player.get_direction() * crouching_mv_speed
			player.move_and_collide(mv_velocity * delta)
			if not player.animation_player.is_playing():
				player.animation_player.play("duck_walk")

		if player.is_on_platform() == false:
			player.fall(mv_velocity)

		if Input.is_action_just_pressed("mv_right"):
			flip_sprites(1)
		elif Input.is_action_just_pressed("mv_left"):
			flip_sprites(-1)

#		fall_velocity.y += Game.gravity * delta
#
#		var collision = player.move_and_collide(fall_velocity * delta)
#		if collision:
#			var damping : float = 0.5
#			var reflect = collision.remainder.bounce(collision.normal)
#			fall_velocity = fall_velocity.bounce(collision.normal) * damping
#			#warning-ignore:return_value_discarded
#			player.move_and_collide(reflect)


		if player.is_on_platform() == true:
			fall_velocity = Vector2.ZERO

		if not Input.is_action_pressed("mv_down"):
			if Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
				player.run(mv_velocity)
			else:
				player.idle()

func flip_sprites(dir):
	if dir > 0:
		sprite.set_flip_h(false)
	else:
		sprite.set_flip_h(true)