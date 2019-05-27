extends Node2D

var player : KinematicBody2D
var my_state_num : int
var warning_issued : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.dropping

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass




func activate():
	drop()

func deactivate():
	pass


func drop():
	var platform = null
	for ground_ray in player.ground_rays:
		if ground_ray.is_colliding() and ground_ray.get_collider() is StaticBody2D:
			platform = ground_ray.get_collider()

	var ray = player.get_node("RayDown")
	# move the ray below the current platform so it doesn't see it.
	var margin = 10.0
	var platform_height = platform.get_child(0).get_shape().get_extents().y * 2
	ray.position = Vector2.DOWN * (player.character_height/2 + platform_height + margin)
	var distance_between_platforms = 150
	ray.set_cast_to(Vector2.DOWN * distance_between_platforms)
	if ray.is_colliding() and ray.get_collider() is StaticBody2D:
		$huhNoise.play()
		move_to_platform(ray.get_collider())

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

	if not warning_issued:
		push_warning("yielding for movement probably isn't the best approach")
		warning_issued = true
	yield(player.tween, "tween_completed")
	player.stop(Vector2.ZERO)

#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		if player.is_on_platform():
			player.stop(Vector2.ZERO)