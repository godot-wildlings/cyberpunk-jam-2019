extends Player_State

#var player : KinematicBody2D
var my_state_num
var sprite : Sprite
var gravity_vector : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.idle
	sprite = $StandingSprite

#warning-ignore:unused_argument
func activate(arguments : Array = []):
	# might receive a velocity argument, but it's ignored
	$StandingSprite.show()

func deactivate():
	$StandingSprite.hide()

func flip_sprites(dir):
	if dir > 0:
		sprite.set_flip_h(false)
	else:
		sprite.set_flip_h(true)

#warning-ignore:unused_argument
func process_state(delta):
	# no movement in idle, so velocity will generally be zero
	velocity = Vector2.ZERO

	if player.state == my_state_num:
		if Input.is_action_just_pressed("mv_right") or Input.is_action_just_pressed("mv_left"):
			player.run()
		elif Input.is_action_just_pressed("jump"):
			player.jump()
		elif Input.is_action_just_pressed("mv_up"):
			print(player.interactive_objects_present)
			if player.interactive_objects_present.size() > 0:
				for object in player.interactive_objects_present:
					if object.get_overlapping_bodies().has(player):
						player.interact_with_object(object)
			else:
				var platform_above = player.get_platform_above()
				if  platform_above != null:
					player.climb(platform_above)
					player.play_random_climb_sfx()
				else:
					player.jump()
		elif Input.is_action_just_pressed("mv_down"):
			var platform_below = player.get_platform_below()
			if platform_below != null:
				player.drop()
			else:
				player.crouch(Vector2.ZERO)

		else: # no important keys pressed
			#warning-ignore:return_value_discarded
			player.move_and_collide(gravity_vector * delta)








