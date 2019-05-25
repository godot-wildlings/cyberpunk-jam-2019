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

onready var animation_player = $AnimationPlayer

#warning-ignore:unused_class_variable
onready var running_sprite = $RunningSprite
#warning-ignore:unused_class_variable
onready var jumping_sprite = $JumpingSprite
#warning-ignore:unused_class_variable
onready var standing_sprite = $StandingSprite
#warning-ignore:unused_class_variable
onready var falling_sprite = $FallingSprite


onready var sprites = [running_sprite, jumping_sprite, standing_sprite, falling_sprite]

#warning-ignore:unused_class_variable
onready var ray_front = $RayFront
#warning-ignore:unused_class_variable
onready var ray_back = $RayBack
onready var ground_rays = [ ray_front, ray_back ]

var gravity : float = 200.0

enum states { idle, running, jumping, climbing, falling, dead }
var state = states.idle

var time_elapsed : float = 0
var ticks : int = 0

var character_height : float

onready var tween = $Tween

var interactive_objects_present : Array = []

var max_health : float = 100.0
var health : float = max_health

var damage_reduction : Dictionary = { # zero to one
		"physical" : 0,
		"electrical" : 0,
		"fire" : 0,
		"acid" : 0,
		"poison" : 0,
		"cold" : 0
}

var actions = [ "scan", "knock", "ghost", "shoot", "slash" ]

var hitstun : bool = false

var current_action : int = 0

signal scanned()


# Called when the node enters the scene tree for the first time.
func _ready():
	Game.player = self
	character_height = $CollisionShape2D.get_shape().get_extents().y * 2
	call_deferred("deferred_ready")

func deferred_ready():
	var err = connect("scanned", Game.main.level, "_on_Player_scanned")
	if err:
		push_warning(self.name + " having trouble connecting signals")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	ticks += 1

	if state == states.running:
		if is_on_platform() == false:
			fall()

		elif Input.is_action_pressed("mv_right") or Input.is_action_pressed("mv_left"):
			run_velocity = Vector2.RIGHT * speed * direction

	elif state == states.jumping:
		jump_velocity.y += gravity * delta

		if jump_velocity.y > -jump_speed/2:
			if is_on_platform():
				land()

	elif state == states.falling:
		fall_velocity.y += gravity * delta
		if is_on_platform() == true:
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
	animation_player.play("idle")

func run(dir : int): # 1 or -1 representing left and right
	run_velocity = Vector2.RIGHT * speed * dir
	modulate_sprites(Color.white)
	state = states.running
	$AnimationPlayer.play("run")

func fall():
	state = states.falling
	modulate_sprites(Color.blue + Color(0.5, 0.5, 0.5))
	animation_player.play("fall")


func modulate_sprites(color):
	for sprite in sprites:
		sprite.set_modulate(color)


func is_on_platform():
	var on_platform = false
	for ray in ground_rays:
		if ray.is_colliding() and ray.get_collider() is StaticBody2D:
			on_platform = true
	return on_platform


#warning-ignore:unused_argument
func _unhandled_key_input(event):

	if Input.is_action_just_pressed("mv_right"):
		if state == states.idle:
			state = states.running
			animation_player.play("run")
		direction = 1
		flip_sprites(direction)
	elif Input.is_action_just_pressed("mv_left"):
		if state == states.idle:
			state = states.running
			animation_player.play("run")
		direction = -1
		flip_sprites(direction)
	elif Input.is_action_just_released("mv_right") or Input.is_action_just_released("mv_left"):
		if state == states.running:
			state = states.idle
			animation_player.stop()
			modulate_sprites(Color.white)
			run_velocity = Vector2.ZERO
	elif Input.is_action_just_pressed("jump"):
		jump()
	elif Input.is_action_just_pressed("mv_up"):
		if state == states.idle:
			if interactive_objects_present.size() > 0:
				for object in interactive_objects_present:
					if object.get_overlapping_bodies().has(self):
						interact_with_object(object)
			else:
				climb()
	elif Input.is_action_just_pressed("mv_down"):
		if state == states.idle:
			drop()
			#crouch()

	elif Input.is_action_just_pressed("action_0"):
		current_action = 0
	elif Input.is_action_just_pressed("action_1"):
		current_action = 1
	elif Input.is_action_just_pressed("action_2"):
		current_action = 2
	elif Input.is_action_just_pressed("action_3"):
		current_action = 3
	elif Input.is_action_just_pressed("action_4"):
		current_action = 4
	elif Input.is_action_just_pressed("action_5"):
		current_action = 5
	elif Input.is_action_just_pressed("action_selected"):
		use_action(current_action)
	elif Input.is_action_just_pressed("next_action"):
		current_action = wrapi(current_action + 1, 0, actions.size())
	elif Input.is_action_just_pressed("prev_action"):
		current_action = wrapi(current_action - 1, 0, actions.size())

func use_action(action_num):
	if actions[action_num] == "scan":
		print("scanning")
		emit_signal("scanned")
	elif actions[action_num] == "ghost":
		print("ghost")
	elif actions[action_num] == "knock":
		print("knock")


func interact_with_object(object):
	if object.has_method("interact"):
		object.interact(self)


func jump():
	if (
			state == states.idle
			or state == states.running
			or (state == states.jumping and jump_num < max_jumps)
	):
		state = states.jumping
		time_of_jump = time_elapsed
		modulate_sprites(Color.magenta + Color(0.5, 0.5, 0.5))
		animation_player.play("jump")
		jump_velocity = Vector2.UP * jump_speed

func climb(): # switch to a higher platform
	var ray = $RayUp
	var distance_between_platforms = 150

	ray.position = Vector2.UP * character_height/2
	ray.set_cast_to(Vector2.UP * distance_between_platforms)
	if ray.is_colliding() and ray.get_collider() is StaticBody2D:
		move_to_platform(ray.get_collider())

func drop(): # switch to a lower platform
	if is_on_platform():
		var platform = null
		for ground_ray in ground_rays:
			if ground_ray.is_colliding() and ground_ray.get_collider() is StaticBody2D:
				platform = ground_ray.get_collider()

		var ray = $RayDown
		# move the ray below the current platform so it doesn't see it.
		var margin = 10.0
		var platform_height = platform.get_child(0).get_shape().get_extents().y * 2
		ray.position = Vector2.DOWN * (character_height/2 + platform_height + margin)
		var distance_between_platforms = 150
		ray.set_cast_to(Vector2.DOWN * distance_between_platforms)
		if ray.is_colliding() and ray.get_collider() is StaticBody2D:
			move_to_platform(ray.get_collider())

func move_to_platform(platform):
	state = states.climbing
	print("moving to a new platform")
	# need to tween this or something
	var my_pos = get_global_position()
	var platform_floor = platform.get_global_position().y - platform.get_child(0).get_shape().get_extents().y

	var new_position = Vector2(my_pos.x, platform_floor - character_height/2)
	tween.interpolate_property(self, "position",
		position, new_position, 0.35,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	$AnimationPlayer.play("jump")
	yield(tween, "tween_completed")
	return_to_idle()

	#set_global_position(new_position)

func _on_InteractiveObject_player_entered(object):
	interactive_objects_present.push_back(object)

func _on_InteractiveObject_player_exited(object):
	interactive_objects_present.erase(object)

func hit(damage, damage_type):
	if hitstun == false:
		# might want to add a direction for knockback later
		var damage_mod : float = 1
		if damage_reduction.has(damage_type):
			damage_mod = 1 - damage_reduction[damage_type]
		health -= damage * damage_mod
		modulate_sprites(Color.red)
		hitstun = true
		$HitstunTimer.start()
		$HealthBar.set_value(health)




func _on_HitstunTimer_timeout():
	modulate_sprites(Color.white)
	hitstun = false
