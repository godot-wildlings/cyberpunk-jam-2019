extends Node2D

var player : KinematicBody2D
var my_state_num : int

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.climbing


#warning-ignore:unused_argument
func activate(arguments : Array = []):
	var ray = player.get_node("RayUp")
	var distance_between_platforms = 150

	ray.position = Vector2.UP * player.character_height/2
	ray.set_cast_to(Vector2.UP * distance_between_platforms)
	if ray.is_colliding() and ray.get_collider() is StaticBody2D:
		$hooahNoise.play()
		move_to_platform(ray.get_collider())
	else:
		player.jump(Vector2.ZERO)

func deactivate():
	pass

#warning-ignore:unused_argument
func _process(delta):
	if player.state == my_state_num:
		if player.is_on_platform():
			player.stop(Vector2.ZERO)

func move_to_platform(platform):
	# need to tween this or something
	var my_pos = player.get_global_position()
	assert(platform.get_child(0) is CollisionShape2D)
	var platform_floor = platform.get_global_position().y - platform.get_child(0).get_shape().get_extents().y

	var new_position = Vector2(my_pos.x, platform_floor - player.character_height/2)
	player.tween.interpolate_property(player, "position",
		player.position, new_position, 0.35,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	player.tween.start()
	player.animation_player.play("jump")

	push_warning("yielding for movement probably isn't the best approach")
	yield(player.tween, "tween_completed")
	player.stop(Vector2.ZERO)

