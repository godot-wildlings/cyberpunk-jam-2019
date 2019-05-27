extends Node2D

var player : KinematicBody2D
var my_state_num : int

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.climbing

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	var ray = player.get_node("RayUp")
	var distance_between_platforms = 150

	ray.position = Vector2.UP * player.character_height/2
	ray.set_cast_to(Vector2.UP * distance_between_platforms)
	if ray.is_colliding() and ray.get_collider() is StaticBody2D:
		$hooahNoise.play()
		player.move_to_platform(ray.get_collider())
	else:
		player.jump()


func deactivate():
	pass

