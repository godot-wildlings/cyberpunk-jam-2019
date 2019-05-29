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


#warning-ignore:unused_argument
func process_state(delta):

	if player.state == my_state_num:
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
			player.set_state(player.states.idle)

