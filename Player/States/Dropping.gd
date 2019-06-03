extends Player_State

#var player : KinematicBody2D
var my_state_num : int
var sprite : Sprite
export var drop_speed : float = 200

var initial_platform : StaticBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.dropping
	sprite = $DroppingSprite
	sprite.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func activate():
	#sprite.show()
	initial_platform = player.get_current_platform()
	drop()

func deactivate():
	sprite.hide()


func drop():
	if player.is_on_ground_plane() != true:
		Game.play_random_sfx($SFX)
		call_deferred("temporarily_disable_collision_bits")
		player.animation_player.play("drop")
		velocity += Vector2.DOWN * drop_speed

#	var platform = player.get_platform_below()
#	if platform != null:
#		#print("Dropping")
#		Game.play_random_sfx($SFX)
#		move_to_platform(platform)

func temporarily_disable_collision_bits():
	initial_platform.set_collision_layer_bit(2, 0)
	initial_platform.set_collision_mask_bit(0, 0)
	yield(get_tree().create_timer(0.6), "timeout")
	initial_platform.set_collision_layer_bit(2, 4)
	initial_platform.set_collision_mask_bit(0, 1)



#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		#var drop_speed :float  = 600.0
		velocity += get_gravity_vector(delta)
		var damping = 0.1
		velocity = move_and_bounce(velocity, delta, damping)


		if player.is_on_platform() and player.get_current_platform() != initial_platform:
			player.stop(Vector2.ZERO)