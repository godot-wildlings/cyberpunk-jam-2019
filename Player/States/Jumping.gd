extends Player_State

#warning-ignore:unused_class_variable
var jump_duration : float = 3.0 # not used yet.
var jump_speed : float = 200.0
var jump_velocity : Vector2 = Vector2.ZERO
var time_of_jump : float
var bounce_damping : float = 0.1

#warning-ignore:unused_class_variable
var jump_num : int = 0 # for double jump tracking
var max_jumps : int = 2

#var player : KinematicBody2D
var my_state_num : int

var sprite : Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_parent().get_parent()
	my_state_num = player.states.jumping
	sprite = $JumpingSprite
	sprite.hide()

func activate(arguments : Array = []):

	var initial_velocity : Vector2 = Vector2.ZERO
	if arguments.size() > 0:
		initial_velocity = arguments[0]
	jump_num += 1
	#sprite.show()

	if jump_num <= max_jumps:
		time_of_jump = Game.time_elapsed
		#sprite.set_modulate(Color.magenta + Color(0.5, 0.5, 0.5))
		player.animation_player.play("jump")
		player.play_random_climb_sfx()
		jump_velocity = initial_velocity + Vector2.UP * jump_speed



func deactivate():
	get_node("JumpingSprite").hide()
	jump_velocity = Vector2.ZERO
	#jump_num = 0

#func flip_sprites(dir):
#	if dir > 0:
#		sprite.set_flip_h(false)
#	else:
#		sprite.set_flip_h(true)

func process_state(delta):
	if player.state == my_state_num:
		move(delta)
		listen_for_exit_conditions()


func move(delta):
	jump_velocity.y += Game.gravity * delta


	var new_vel = move_and_bounce(jump_velocity, delta, bounce_damping)

	if sign(new_vel.y) != sign(jump_velocity.y): # hit the ground?
		if player.is_on_platform():
			player.land(jump_velocity)

	velocity = new_vel # important to update this every frame, even if we don't use it

func listen_for_exit_conditions():
		if Input.is_action_just_pressed("jump") and jump_num < max_jumps:
			player.jump(jump_velocity)
		elif Input.is_action_just_pressed("mv_up") and jump_num < max_jumps:
			player.jump(jump_velocity)


