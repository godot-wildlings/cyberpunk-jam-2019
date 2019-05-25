extends KinematicBody2D

# Declare member variables here. Examples:
var speed : float = 200

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
			state = states.falling
		else:
			if Input.is_action_pressed("mv_right"):
				run_velocity = Vector2.RIGHT * speed
				flip_sprites(false)
				#$Sprite.set_flip_h(false) # may have to change to scale = Vector2(1,1) later
			elif Input.is_action_pressed("mv_left"):
				run_velocity = Vector2.LEFT * speed
				flip_sprites(true)
				#$Sprite.set_flip_h(true) # may have to change to scale = Vector2(-1,1) later

	elif state == states.jumping:
		jump_velocity.y += gravity * delta

		if jump_velocity.y > 0:
			if is_on_ground():
				return_to_idle()

	#warning-ignore:return_value_discarded
	move_and_slide(run_velocity + jump_velocity)

	if Input.is_action_just_pressed("jump") and jump_num < max_jumps:
		state = states.jumping
		jump_num += 1

#	if state == states.jumping and ticks % 20 == 0:
#		print(self.name, " jump_velocity == " , jump_velocity)

func flip_sprites(flip):
	for sprite in sprites:
		sprite.set_flip_h(flip)

func return_to_idle():
	state = states.idle
	jump_num = 0
	jump_velocity = Vector2.ZERO
	if Input.is_action_pressed("mv_left") == false and Input.is_action_pressed("mv_right") == false:
		run_velocity = Vector2.ZERO
		modulate_sprites(Color.white)

func modulate_sprites(color):
	for sprite in sprites:
		sprite.set_modulate(color)


func is_on_ground():
	if $RayCast2D.is_colliding():
		if $RayCast2D.get_collider() is StaticBody2D:
			return true


#warning-ignore:unused_argument
func _unhandled_key_input(event):
	if Input.is_action_just_pressed("mv_right") or Input.is_action_just_pressed("mv_left"):
		if state == states.idle:
			state = states.running
			$AnimationPlayer.play("run")

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
