extends Node2D

var player : KinematicBody2D
var my_state_num : int

var warning_issued: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.climbing


#warning-ignore:unused_argument
func activate(arguments : Array = []):
	if arguments.size() > 0:
		$hooahNoise.play()
		move_to_platform(arguments[0])
	else:
		player.jump(Vector2.ZERO)

func deactivate():
	pass

#warning-ignore:unused_argument
func process_state(delta):
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

	if not warning_issued:
		push_warning("yielding for movement probably isn't the best approach")
		warning_issued = true
	yield(player.tween, "tween_completed")
	player.stop(Vector2.ZERO)

