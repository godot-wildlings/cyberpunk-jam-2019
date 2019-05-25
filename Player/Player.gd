extends KinematicBody2D

# Declare member variables here. Examples:
var speed : float = 200

var direction : int = 1
#warning-ignore:unused_class_variable
var velocity : Vector2 = Vector2.ZERO

var run_velocity : Vector2 = Vector2.ZERO

#warning-ignore:unused_class_variable
var jump_duration : float = 3.0 # not used yet.
var jump_speed : float = 100.0
var jump_velocity : Vector2 = Vector2.ZERO
var time_of_jump : float

#warning-ignore:unused_class_variable
var jump_num : int = 0 # for double jump tracking
var max_jumps : int = 2

var fall_velocity : Vector2 = Vector2.ZERO


#warning-ignore:unused_class_variable
onready var running_sprite = $RunningSprite
#warning-ignore:unused_class_variable
onready var jumping_sprite = $JumpingSprite
#warning-ignore:unused_class_variable
onready var standing_sprite = $StandingSprite

onready var sprites = [running_sprite, jumping_sprite, standing_sprite]

var gravity : float = 200.0

enum states { idle, running, jumping, falling, dead }
var state = states.idle

var time_elapsed : float = 0
var ticks : int = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	Game.player = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	ticks += 1

	if state == states.running:
		if is_on_ground() == false:
			fall()

		elif Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
			run_velocity = Vector2.RIGHT * speed * direction

	elif state == states.jumping:
		jump_velocity.y += gravity * delta

		if jump_velocity.y > -jump_speed/2:
			if is_on_ground():
				land()

	elif state == states.falling:
		fall_velocity.y += gravity * delta
		if is_on_ground() == true:
			land()

	#warning-ignore:return_value_discarded
	move_and_slide(run_velocity + jump_velocity + fall_velocity)

	if Input.is_action_just_pressed("jump") and jump_num < max_jumps:
		state = states.jumping
		jump_num += 1

#	if state == states.jumping and ticks % 20 == 0:
#		print(self.name, " jump_velocity == " , jump_velocity)

func flip_sprites(direction):
	var flip = false
	if direction == -1:
		flip = true
	for sprite in sprites:
		sprite.set_flip_h(flip)

func land():
	jump_num = 0
	jump_velocity = Vector2.ZERO
	fall_velocity = Vector2.ZERO
	modulate_sprites(Color.white)

	if Input.is_action_pressed("mv_left") or Input.is_action_pressed("mv_right"):
		run(direction)
	else:
		return_to_idle()

func return_to_idle():
	state = states.idle
	run_velocity = Vector2.ZERO

func run(dir : int): # 1 or -1 representing left and right
	run_velocity = Vector2.RIGHT * speed * dir
	modulate_sprites(Color.white)
	state = states.running

func fall():
	state = states.falling
	modulate_sprites(Color.blue)


func modulate_sprites(color):
	for sprite in sprites:
		sprite.set_modulate(color)


func is_on_ground():
	var on_ground = false
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() is StaticBody2D:
			on_ground = true
	return on_ground


#warning-ignore:unused_argument
func _unhandled_key_input(event):

	if Input.is_action_just_pressed("mv_right"):
		if state == states.idle:
			state = states.running
			$AnimationPlayer.play("run")
		direction = 1
		flip_sprites(direction)

	elif Input.is_action_just_pressed("mv_left"):
		if state == states.idle:
			state = states.running
			$AnimationPlayer.play("run")
		direction = -1
		flip_sprites(direction)


	elif Input.is_action_just_released("mv_right") or Input.is_action_just_released("mv_left"):
		if state == states.running:
			state = states.idle
			$AnimationPlayer.stop()
			modulate_sprites(Color.white)
			run_velocity = Vector2.ZERO


	if Input.is_action_just_pressed("jump"):
		if (
				state == states.idle
				or state == states.running
				or (state == states.jumping and jump_num < max_jumps)
		):
			state = states.jumping
			time_of_jump = time_elapsed
			modulate_sprites(Color.magenta + Color(0.5, 0.5, 0.5))
			$AnimationPlayer.play("jump")
			jump_velocity = Vector2.UP * jump_speed
