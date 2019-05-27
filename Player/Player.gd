extends KinematicBody2D

#warning-ignore:unused_class_variable
var speed : float = 200

var direction : int = 1
#warning-ignore:unused_class_variable
#var velocity : Vector2 = Vector2.ZERO

#warning-ignore:unused_class_variable
onready var animation_player = $AnimationPlayer

#warning-ignore:unused_class_variable
onready var running_sprite = $States/Running/RunningSprite
#warning-ignore:unused_class_variable
onready var jumping_sprite = $States/Jumping/JumpingSprite
#warning-ignore:unused_class_variable
onready var standing_sprite = $States/Idle/StandingSprite
#warning-ignore:unused_class_variable
onready var falling_sprite = $States/Falling/FallingSprite
#warning-ignore:unused_class_variable
onready var entering_sprite = $States/Entering/EnteringSprite
#warning-ignore:unused_class_variable
onready var exiting_sprite = $States/Exiting/ExitingSprite


onready var sprites = [running_sprite, jumping_sprite, standing_sprite, falling_sprite, entering_sprite, exiting_sprite]

#warning-ignore:unused_class_variable
onready var ray_front = $RayFront
#warning-ignore:unused_class_variable
onready var ray_back = $RayBack
onready var ground_rays = [ ray_front, ray_back ]

onready var gun = $Gun



enum states { idle, running, jumping, climbing, dropping, falling, dead, entering, hidden, exiting }
var state = states.idle

var state_names : Dictionary = {
		states.idle: "Idle",
		states.running: "Running",
		states.jumping: "Jumping",
		states.climbing: "Climbing",
		states.dropping: "Dropping",
		states.falling: "Falling",
		states.dead: "Dead",
		states.entering: "Entering",
		states.hidden: "Hidden",
		states.exiting: "Exiting"
}

var current_state_node : Node2D


var character_height : float

onready var tween = $Tween

var interactive_objects_present : Array = []

var max_health : float = 100.0
var health : float = max_health

var max_ammo : float = 16
var ammo : float = max_ammo

#warning-ignore:unused_class_variable
var damage_types = Game.damage_types
var damage_reduction : Dictionary = { # zero to one
		damage_types.physical : 0.5,
		damage_types.electrical : 0,
		damage_types.fire : 0,
		damage_types.acid : 0,
		damage_types.poison : 0,
		damage_types.cold : 0
}

enum actions { scan, knock, ghost, shoot, slash }
#warning-ignore:unused_class_variable
var action_names = {
		actions.scan : "scan",
		actions.knock : "knock",
		actions.ghost : "ghost",
		actions.shoot : "shoot",
		actions.slash : "slash"
}

var hitstun : bool = false

var current_action = 0 setget set_current_action


func _ready():
	hide_sprites()
	Game.player = self
	character_height = $CollisionShape2D.get_shape().get_extents().y * 2
	#call_deferred("deferred_ready")
	holster_gun()
	set_state(states.idle)


func set_state(state_num, arguments : Array = []):
	if current_state_node != null and current_state_node.has_method("deactivate"):
		current_state_node.deactivate()

	if $States.has_node(state_names[state_num]):
		current_state_node = $States.get_node(state_names[state_num])
		if arguments.size() > 0:
			current_state_node.activate(arguments)
		else:
			current_state_node.activate()

	state = state_num

func hide_sprites():
	for sprite in sprites:
		sprite.hide()

func flip_sprites(direction):
	var flip = false
	if direction == -1:
		flip = true
	for sprite in sprites:
		sprite.set_flip_h(flip)
	$Gun.set_scale(Vector2(abs($Gun.get_scale().x) * direction, $Gun.get_scale().y))

func get_direction() -> int:
	return direction

func run(initial_velocity : Vector2 = Vector2.ZERO):
	set_state(states.running, [Vector2(initial_velocity.x, 0)])

func fall(initial_velocity : Vector2 = Vector2.ZERO):
	set_state(states.falling, [initial_velocity])

func land(fall_velocity):
	if Input.is_action_pressed("mv_left") or Input.is_action_pressed("mv_right"):
		run(fall_velocity)
	else:
		stop(fall_velocity)

func stop(initial_velocity):
	# might want some screech to a halt animation, or drift distance
	set_state(states.idle, [initial_velocity])

func idle():
	set_state(states.idle, [Vector2.ZERO])

#func return_to_idle():
#	state = states.idle
#	run_velocity = Vector2.ZERO
#	animation_player.play("idle")


func enter():
	set_state(states.entering)

func exit():
	set_state(states.exiting)


func modulate_sprites(color):
	for sprite in sprites:
		sprite.set_modulate(color)


func is_on_platform():
	var on_platform = false
	for ray in ground_rays:
		if ray.is_colliding() and ray.get_collider() is StaticBody2D:
			on_platform = true
	return on_platform

func get_platform_above() -> StaticBody2D:
	var ray = get_node("RayUp")
	var distance_between_platforms = 150

	ray.position = Vector2.UP * character_height/2
	ray.set_cast_to(Vector2.UP * distance_between_platforms)
	if ray.is_colliding() and ray.get_collider() is StaticBody2D:
		return ray.get_collider()
	else:
		return null

func _process(delta):
	current_state_node.process_state(delta)

#warning-ignore:unused_argument
func _unhandled_key_input(event):

	if Input.is_action_just_pressed("action_0"):
		self.current_action = 0
	elif Input.is_action_just_pressed("action_1"):
		self.current_action = 1
	elif Input.is_action_just_pressed("action_2"):
		self.current_action = 2
	elif Input.is_action_just_pressed("action_3"):
		self.current_action = 3
	elif Input.is_action_just_pressed("action_4"):
		self.current_action = 4
	elif Input.is_action_just_pressed("action_5"):
		self.current_action = 5
	elif Input.is_action_just_pressed("action_selected"):
		use_action(current_action)
	elif Input.is_action_just_pressed("next_action"):
		self.current_action = wrapi(current_action + 1, 0, actions.size())
	elif Input.is_action_just_pressed("prev_action"):
		self.current_action = wrapi(current_action - 1, 0, actions.size())

	if Input.is_action_just_pressed("mv_right"):
		direction = 1
		flip_sprites(direction)
	elif Input.is_action_just_pressed("mv_left"):
		direction = -1
		flip_sprites(direction)


func get_direction_pressed() -> int:
	if Input.is_action_pressed("mv_right"):
		return 1
	elif Input.is_action_pressed("mv_left"):
		return -1
	else:
		return 0

func set_current_action(value):
	if value == actions.shoot:
		draw_gun()
	else:
		holster_gun()
	current_action = value

func draw_gun():
	gun.show()

func holster_gun():
	gun.hide()


func use_action(action_num):
	if action_num == actions.scan:
		$Actions/Scan.use()
	elif action_num == actions.ghost:
		print("ghost")
	elif action_num == actions.knock:
		knock()
	elif action_num == actions.shoot:
		shoot()


func knock():
	# unlock nearby locked objects..
	$Actions/Knock.use()


func shoot():
	if ammo > 0:
		if has_node("Gun") and get_node("Gun").has_method("shoot"):
			get_node("Gun").shoot()
			ammo -= 1
			$AmmoBar.set_value(ammo/max_ammo * 100)


func interact_with_object(object):
	if object.has_method("interact"):
		object.interact(self)

func jump(initial_velocity : Vector2 = Vector2.ZERO):
	set_state(states.jumping, [initial_velocity])

func climb(platform : StaticBody2D): # switch to a higher platform
	# note: Player ray is set to only scan bitmask 3: platforms
	set_state(states.climbing, [platform])


func drop(): # switch to a lower platform
	if is_on_platform():
		set_state(states.dropping)

#func move_to_platform(platform):
#	state = states.climbing
#	print("moving to a new platform")
#	# need to tween this or something
#	var my_pos = get_global_position()
#	assert(platform.get_child(0) is CollisionShape2D)
#	var platform_floor = platform.get_global_position().y - platform.get_child(0).get_shape().get_extents().y
#
#	var new_position = Vector2(my_pos.x, platform_floor - character_height/2)
#	tween.interpolate_property(self, "position",
#		position, new_position, 0.35,
#		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
#	tween.start()
#	$AnimationPlayer.play("jump")
#	yield(tween, "tween_completed")
#	set_state(states.idle)

	#set_global_position(new_position)

func _on_InteractiveObject_player_entered(object):
	interactive_objects_present.push_back(object)

func _on_InteractiveObject_player_exited(object):
	interactive_objects_present.erase(object)

func hit(damage : float, damage_type : int):
	if hitstun == false:
		# might want to add a direction for knockback later
		var damage_mod : float = 1
		if damage_reduction.has(damage_type):
			print("received damage: type == ", damage_type, ": " , Game.damage_type_names[damage_type])
			print("damage_reduction == ", damage_reduction[damage_type])
			damage_mod = 1 - damage_reduction[damage_type]
		health -= damage * damage_mod
		$SFX/OofNoise.play()
		modulate_sprites(Color.red)
		hitstun = true
		$HitstunTimer.start()
		$HealthBar.set_value(health)

func recover_health(amount : float):
	health = min(health + amount, max_health)
	$HealthBar.set_value(health)

func add_ammo(amount: int):
	ammo = min(ammo + amount, max_ammo)
	$AmmoBar.set_value(ammo/max_ammo * 100)

func _on_HitstunTimer_timeout():
	modulate_sprites(Color.white)
	hitstun = false
