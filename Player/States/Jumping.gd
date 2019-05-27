extends Node2D

#warning-ignore:unused_class_variable
var jump_duration : float = 3.0 # not used yet.
var jump_speed : float = 100.0
var jump_velocity : Vector2 = Vector2.ZERO
var time_of_jump : float

#warning-ignore:unused_class_variable
var jump_num : int = 0 # for double jump tracking
var max_jumps : int = 2

var player : KinematicBody2D
var my_state_num : int

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.jumping

func activate(arguments : Array = []):

	var initial_velocity : Vector2 = Vector2.ZERO
	if arguments.size() > 0:
		initial_velocity = arguments[0]
	jump_num += 1
	get_node("JumpingSprite").show()

	if jump_num <= max_jumps:
		time_of_jump = Game.time_elapsed
		$JumpingSprite.set_modulate(Color.magenta + Color(0.5, 0.5, 0.5))
		player.animation_player.play("jump")
		$huNoise.play()
		jump_velocity = initial_velocity + Vector2.UP * jump_speed



func deactivate():
	get_node("JumpingSprite").hide()
	jump_velocity = Vector2.ZERO
	jump_num = 0


func _process(delta):
	if player.state == my_state_num:
		jump_velocity.y += Game.gravity * delta

		#warning-ignore:return_value_discarded
		player.move_and_collide(jump_velocity * delta)

		if sign(jump_velocity.y) > 0:
			if player.is_on_platform():
				print("landing")
				player.land(jump_velocity)


