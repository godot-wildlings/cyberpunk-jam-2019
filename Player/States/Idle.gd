extends Node2D

var player : KinematicBody2D
var my_state_num

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.idle

#warning-ignore:unused_argument
func activate(arguments : Array = []):
	# might receive a velocity argument, but it's ignored
	$StandingSprite.show()

func deactivate():
	$StandingSprite.hide()

#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		if Input.is_action_just_pressed("mv_right") or Input.is_action_just_pressed("mv_left"):
			player.run()
		elif Input.is_action_just_pressed("jump"):
			player.jump()
		elif Input.is_action_just_pressed("mv_up"):
			if player.interactive_objects_present.size() > 0:
				for object in player.interactive_objects_present:
					if object.get_overlapping_bodies().has(player):
						player.interact_with_object(object)
			else:
				var platform_above = player.get_platform_above()
				if  platform_above != null:
					player.climb(platform_above)
				else:
					player.jump()
		elif Input.is_action_just_pressed("mv_down"):
			player.drop()





