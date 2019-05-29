extends KinematicBody2D

#warning-ignore:unused_class_variable
var speed : float = 200

var direction : int = 1
#warning-ignore:unused_class_variable
var velocity : Vector2 = Vector2.ZERO

#warning-ignore:unused_class_variable
onready var animation_player = $AnimationPlayer


#warning-ignore:unused_class_variable
onready var ray_front = $RayFront
#warning-ignore:unused_class_variable
onready var ray_back = $RayBack
onready var ground_rays = [ ray_front, ray_back ]
#warning-ignore:unused_class_variable
onready var tween = $Tween
#warning-ignore:unused_class_variable
onready var gun = $Actions/Attack/Gun

enum states { idle, running, jumping, climbing, dropping, falling, crouching, dead, entering, hidden, exiting, attacking, hit }
var state = states.idle
var state_names : Dictionary = {
		states.idle: "Idle",
		states.running: "Running",
		states.jumping: "Jumping",
		states.climbing: "Climbing",
		states.dropping: "Dropping",
		states.falling: "Falling",
		states.crouching: "Crouching",
		states.dead: "Dead",
		states.entering: "Entering",
		states.hidden: "Hidden",
		states.exiting: "Exiting",
		states.attacking: "Attacking",
		states.hit: "Hit"
}

var current_state_node : Node2D

var character_height : float
var interactive_objects_present : Array = []

var max_health : float = 100.0
var health : float = max_health

var max_ammo : float = 16
var ammo : float = max_ammo

var keys_held : int = 0

#warning-ignore:unused_class_variable
var damage_types = Game.damage_types
#warning-ignore:unused_class_variable
var damage_reduction : Dictionary = { # zero to one
		damage_types.physical : 0.5,
		damage_types.electrical : 0,
		damage_types.fire : 0,
		damage_types.acid : 0,
		damage_types.poison : 0,
		damage_types.cold : 0
}

enum actions { scan, attack }
#warning-ignore:unused_class_variable
var action_names = {
		actions.scan : "scan", # same as iReal
		actions.attack : "attack"

}

#warning-ignore:unused_class_variable
var action_descriptions = {
		actions.scan : "iReal(TM): More real than real; a better world",
		actions.attack : "Punch or Shoot"
}

#var hitstun : bool = false

var current_action_num : int = 0 setget set_current_action_num

#warning-ignore:unused_class_variable
var iReal_active : bool = false

func _ready():
	hide_sprites()
	Game.player = self
	character_height = $CollisionShape2D.get_shape().get_extents().y * 2
	#call_deferred("deferred_ready")
	set_state(states.idle)
	$Actions.show()
	call_deferred("deferred_ready")

func deferred_ready():
	$Actions/Attack.holster_gun()


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
	# not yet implemented in states.
	for state_node in $States.get_children():
		if state_node.has_method("hide_sprites"):
			state_node.hide_sprites()
#	for sprite in sprites:
#		sprite.hide()

func flip_sprites(direction):
	for state_node in $States.get_children():
		if state_node.has_method("flip_sprites"):
			state_node.flip_sprites(direction)

#	var flip = false
#	if direction == -1:
#		flip = true
#	for sprite in sprites:
#		sprite.set_flip_h(flip)
#	gun.set_scale(Vector2(abs(gun.get_scale().x) * direction, gun.get_scale().y))

func get_direction() -> int:
	return direction

func run(initial_velocity : Vector2 = Vector2.ZERO):
	set_state(states.running, [Vector2(initial_velocity.x, 0)])

func fall(initial_velocity : Vector2 = Vector2.ZERO):
	set_state(states.falling, [initial_velocity])

func land(fall_velocity):
	$States/Jumping.jump_num = 0
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

func crouch(initial_velocity):
	set_state(states.crouching, [initial_velocity])

func enter(object):
	set_state(states.entering, [object])

func exit():
	set_state(states.exiting)

# move this to state
#func modulate_sprites(color):
#	for sprite in sprites:
#		sprite.set_modulate(color)


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

func get_platform_below() -> StaticBody2D:
	var platform = null
	for ground_ray in ground_rays:
		if ground_ray.is_colliding() and ground_ray.get_collider() is StaticBody2D:
			platform = ground_ray.get_collider()

	var ray = get_node("RayDown")
	# move the ray below the current platform so it doesn't see it.
	var margin = 10.0
	var platform_height = 100
	if platform != null and platform.get_child_count() > 0:
		platform_height = platform.get_child(0).get_shape().get_extents().y * 2
	ray.position = Vector2.DOWN * (character_height/2 + platform_height + margin)
	var distance_between_platforms = 150
	ray.set_cast_to(Vector2.DOWN * distance_between_platforms)
	if ray.is_colliding() and ray.get_collider() is StaticBody2D:
		return ray.get_collider()
	else:
		return null

func _process(delta):
	current_state_node.process_state(delta)

#warning-ignore:unused_argument
func _unhandled_key_input(event):

#	if Input.is_action_just_pressed("action_0"):
#		self.current_action_num = 0
#	elif Input.is_action_just_pressed("action_1"):
#		self.current_action_num = 1
#	elif Input.is_action_just_pressed("action_2"):
#		self.current_action_num = 2
#	elif Input.is_action_just_pressed("action_3"):
#		self.current_action_num = 3
#	elif Input.is_action_just_pressed("action_4"):
#		self.current_action_num = 4
#	elif Input.is_action_just_pressed("action_5"):
#		self.current_action_num = 5
#	if Input.is_action_just_pressed("action_selected"):
#		use_action(current_action_num)
#	elif Input.is_action_just_pressed("next_action"):
#		self.current_action_num = wrapi(current_action_num + 1, 0, actions.size())
#	elif Input.is_action_just_pressed("prev_action"):
#		self.current_action_num = wrapi(current_action_num - 1, 0, actions.size())

	if Input.is_action_just_pressed("mv_right"):
		direction = 1
		flip_sprites(direction)
	elif Input.is_action_just_pressed("mv_left"):
		direction = -1
		flip_sprites(direction)

	if Input.is_action_just_pressed("attack"):
		attack()
	elif Input.is_action_just_pressed("scan"):
		scan()

func get_direction_pressed() -> int:
	if Input.is_action_pressed("mv_right"):
		return 1
	elif Input.is_action_pressed("mv_left"):
		return -1
	else:
		return 0

func set_current_action_num(value):
	current_action_num = value



func use_action(action_num):
	if action_num == actions.scan:
		scan()
	elif action_num == actions.attack:
		attack()



func scan():
	$Actions/Scan.use()

func attack():
	$Actions/Attack.use()
	set_state(states.attacking)

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



func _on_InteractiveObject_player_entered(object):
	interactive_objects_present.push_back(object)

func _on_InteractiveObject_player_exited(object):
	interactive_objects_present.erase(object)

func pickup_key():
	keys_held += 1


func hit(damage : float, damage_type : int):
	if state != states.hit:
		set_state(states.hit, [damage, damage_type])


func recover_health(amount : float):
	health = min(health + amount, max_health)
	$HealthBar.set_value(health)

func add_ammo(amount: int):
	ammo = min(ammo + amount, max_ammo)
	$AmmoBar.set_value(ammo/max_ammo * 100)

#func _on_HitstunTimer_timeout():
#	modulate_sprites(Color.white)
#	hitstun = false
