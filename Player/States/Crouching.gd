"""
Crouching happens when you're standing on the bottom platform and push down
Why not on other platforms?
"""

extends Player_State




#var player : KinematicBody2D
var my_state_num
var sprite : Sprite
var fall_velocity : Vector2 = Vector2.ZERO
# velocity : Vector2 is inherited from state.gd and initialized in Player.set_state

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

	# set the player back on the platform, because we made the collision area smaller, so they're floating.
	#warning-ignore:return_value_discarded
	player.move_and_collide(Vector2.DOWN * y_delta)




func deactivate():
	$CrouchingSprite.hide()
	var shape = player.get_node("CollisionShape2D").get_shape()
	var y_delta = shape.get_extents().y/3 # HAX <-- This isn't the correct distance, it's just close enough
	shape.set_extents(Vector2(shape.get_extents().x, shape.get_extents().y*2))

	#warning-ignore:return_value_discarded
	player.move_and_collide(Vector2.UP * y_delta)

	player.animation_player.stop()

#warning-ignore:unused_argument
func process_state(delta):

	if player.state == my_state_num:

		move(delta)
		listen_for_exit_conditions()


func move(delta):
		var mv_velocity = Vector2.ZERO
		var crouching_mv_speed = player.speed / 3
		if Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
			mv_velocity = Vector2.RIGHT * player.get_direction() * crouching_mv_speed
			var damping = 0.1
			var new_vel = move_and_bounce(mv_velocity, delta, damping)
			velocity = new_vel # required for state changing
			if not player.animation_player.is_playing():
				player.animation_player.play("duck_walk")

		if player.is_on_platform() == false:
			player.fall(mv_velocity) # fall could actually get the velocity without passing it

		if Input.is_action_just_pressed("mv_right"):
			flip_sprites(1)
		elif Input.is_action_just_pressed("mv_left"):
			flip_sprites(-1)


		if player.is_on_platform() == true:
			fall_velocity = Vector2.ZERO


func listen_for_exit_conditions():
		if not Input.is_action_pressed("mv_down"):
			if Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
				player.run(velocity)
			else:
				player.idle()

func flip_sprites(dir):
	if dir > 0:
		sprite.set_flip_h(false)
	else:
		sprite.set_flip_h(true)