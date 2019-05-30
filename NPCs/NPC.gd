extends KinematicBody2D

onready var decision_timer : Timer = $Timers/DecisionTimer
onready var reload_timer : Timer = $Timers/ReloadTimer
onready var ghost_timer : Timer = $Timers/GhostTimer
#onready var shot_timer : Timer = $Timers/ShotTimer
onready var death_timer : Timer = $Timers/DeathTimer
onready var recognition_timer : Timer = $Timers/RecognitionTimer

onready var ghost_tscn : PackedScene = preload("res://GhostTrailEffect/GhostTrail.tscn") as PackedScene
onready var gun : Node2D = $EnemyGun

enum character_types { citizen, ghost, sinner }
export (character_types) var character_type : int = character_types.citizen

enum attitudes { ignore, fight, flee }
enum attack_types { ranged, melee }
#export var friendly : bool = true
export (attitudes) var initial_attitude = attitudes.ignore
export (attitudes) var scanned_attitude = attitudes.ignore
export (attack_types) var attack_type = attack_types.ranged
export var damage_output_per_hit = 25
export (Game.damage_types) var melee_damage_type

#warning-ignore:unused_class_variable
export var can_fly : bool = false

var current_attitude
var my_color : Color # to make up for lack of artwork, we'll use lots of colors

var direction : int = 1
var speed : float = 80.0
var scanned : bool = false
#var can_shoot : bool = true

var current_sprite

enum states { initializing, ready, passive, alert, aggressive, dead, frozen }
var state = states.initializing

enum weapon_states { reloading, ready }
var melee_weapon_state = weapon_states.reloading
var ranged_weapon_state = weapon_states.reloading

onready var ranged_line_of_sight = $GunRange
onready var melee_range = $MeleeRange

var current_target : Node2D # probably the player

export var max_health : float = 50.0
var health : float = max_health

var intended_movement_vector : Vector2 = Vector2.ZERO
var gravity_vector : Vector2 = Vector2.ZERO

#warning-ignore:unused_class_variable
var damage_types = Game.damage_types
export var damage_reduction : Dictionary = { # zero to one
		damage_types.physical : 0,
		damage_types.electrical : 0,
		damage_types.fire : 0,
		damage_types.acid : 0,
		damage_types.poison : 0,
		damage_types.cold : 0
}

var warning_issued : bool = false


func _ready():
	# we need a lot of NPCs, but we don't have any artwork, so I'll colorize these.
	colorize_sprites()
	display_correct_sprite()

	#warning-ignore:return_value_discarded
	ghost_timer.connect("timeout", self, "_on_GhostTimer_timeout")
	#warning-ignore:return_value_discarded
	#shot_timer.connect("timeout", self, "_on_ShotTimer_timeout")
	decision_timer.start()
	reload_timer.start()
	state = states.passive


	current_sprite = $Sprites/RealSprite

	$AnimationPlayer.play("walk")
	gun.visible = false

	call_deferred("deferred_ready")

func display_correct_sprite():
	if not scanned:
		current_sprite = $Sprites/RealSprite
	elif character_type == character_types.ghost:
		current_sprite = $Sprites/GhostSprite
	elif character_type == character_types.sinner:
		current_sprite = $Sprites/SinnerSprite

	for sprite in $Sprites.get_children():
		sprite.hide()
	current_sprite.show()


func deferred_ready():
	if initial_attitude == attitudes.fight:
		enable_collisions_with_player()

func enable_collisions_with_player():
	var player_bit = 0
	var player_value = 1
	set_collision_mask_bit(player_bit, player_value)

func update_attitude():
	if scanned == false:
		current_attitude = initial_attitude
	else:
		current_attitude = scanned_attitude

func colorize_sprites():
	var random_colors = [
			Color.khaki,
			Color.azure,
			Color.beige,
			Color.bisque,
			Color.burlywood,
			Color.brown,
			Color.darkkhaki,
			Color.sienna,
			Color.goldenrod
	]

	my_color = random_colors[randi()%random_colors.size()]
	saturate_sprite()

func saturate_sprite():
	$Sprites/RealSprite.set_self_modulate(my_color)

func desaturate_sprite():
	$Sprites/RealSprite.set_self_modulate(Color.white)

func _process(delta):
	if state == states.dead:
		return

	if state == states.passive:

		avoid_ledges()

		#warning-ignore:unused_variable
		intended_movement_vector = Vector2.RIGHT * direction * speed

	elif state == states.aggressive:
		seek_effective_range(delta)

	update_attitude()
	consider_punching()
	consider_shooting()
	consider_fleeing()

	move(delta)

func avoid_ledges():
	var ray = $Rays/GroundDectorFront
	if not ( ray.is_colliding() ):
		switch_direction(direction * -1)


func move(delta):

	gravity_vector.y += Game.gravity * delta


	#warning-ignore:return_value_discarded
	move_and_slide( (intended_movement_vector + gravity_vector))


	if is_on_floor():
		gravity_vector.y = 0.00


#warning-ignore:unused_argument
func seek_effective_range(delta):
	if attack_type == attack_types.ranged:
		if ranged_line_of_sight.get_overlapping_bodies().has(current_target):
			var my_pos = get_global_position()
			var target_pos = current_target.get_global_position()
			var effective_range = 250
			if my_pos.distance_squared_to(target_pos) > effective_range * effective_range:
				intended_movement_vector = Vector2.RIGHT * direction * speed
				#warning-ignore:return_value_discarded
			else:
				intended_movement_vector = Vector2.RIGHT * -direction * speed
				#warning-ignore:return_value_discarded


		else: # lost sight of the player
			state = states.passive
	elif attack_type == attack_types.melee:
		intended_movement_vector = Vector2.RIGHT * direction * speed


func consider_fleeing():
	if current_attitude == attitudes.flee:

		if not warning_issued:
			push_warning("NPCs still need fleeing behaviour")
			warning_issued = true
		current_attitude = attitudes.passive



func consider_punching():
	if current_attitude == attitudes.fight and attack_type == attack_types.melee:
		if melee_weapon_state == weapon_states.ready:
			if melee_range.get_overlapping_bodies().has(Game.player):
				current_target = Game.player
				melee_attack(current_target)

func melee_attack(object):
	if object.has_method("hit"):
		object.hit(damage_output_per_hit, melee_damage_type)
		melee_weapon_state = weapon_states.reloading
		reload_timer.start()

		push_warning("NPCs still need melee attack animation")


func consider_shooting():
	if not recognition_timer.is_stopped():
		return

	if current_attitude == attitudes.fight and attack_type == attack_types.ranged:
		if ranged_line_of_sight.get_overlapping_bodies().has(Game.player):
			$EnemySightedLabel.show()
			current_target = Game.player
			state = states.aggressive # track the player instead of switching dir randomly


			recognition_timer.start()

			#$RecognitionTimer.start() # small delay between sighting target and shooting target to make it seem more plausible
		else:
			$EnemySightedLabel.hide()

func shoot(target):
	if is_instance_valid(gun) and gun.has_method("shoot"):
		if ranged_weapon_state == weapon_states.ready:
			gun.shoot(target)
			ranged_weapon_state = weapon_states.reloading
			reload_timer.start()



func _on_GhostTimer_timeout():
	if state != states.initializing and state != states.dead:
		var ghost_instance : Node2D = ghost_tscn.instance()
		get_parent().add_child(ghost_instance)
		ghost_instance.position = position
		ghost_instance.texture = current_sprite.texture
		ghost_instance.frame = current_sprite.frame
		ghost_instance.rotation = current_sprite.rotation
		ghost_instance.flip_h = current_sprite.flip_h

func get_direction() -> int:
	return direction

func switch_direction(dir):
	if direction != dir:
		ranged_line_of_sight.scale.x *= -1
		if dir > 0:
			$Sprites/RealSprite.set_flip_h(false)
		else:
			$Sprites/RealSprite.set_flip_h(true)
	direction = dir


func _on_DecisionTimer_timeout():
	if state != states.aggressive:
		# change directions randomly
		if randf() < 0.5:
			switch_direction(-1)
		else:
			switch_direction(1)
	elif state == states.aggressive:
		# chase the player
		follow(current_target)

	decision_timer.start()

func follow(target):
	var my_pos = get_global_position()
	var target_pos = target.get_global_position()
	var new_dir = sign((target_pos - my_pos).x)
	if new_dir != direction:
		switch_direction(new_dir)

func _on_ReloadTimer_timeout():
	melee_weapon_state = weapon_states.ready
	ranged_weapon_state = weapon_states.ready
	#can_shoot = true

#func _on_ShotTimer_timeout():
#	can_shoot = true

func _on_RecognitionTimer_timeout():

	shoot(Game.player)

func _on_Player_scanned():
	scanned = true
	display_correct_sprite()
	desaturate_sprite()
	if scanned_attitude == attitudes.fight:
		enable_collisions_with_player()





func hit(damage, damage_type):
	if state != states.dead:
		if not scanned:
			scanned = true

		if current_attitude == attitudes.ignore:
			if character_type == character_types.citizen:
				if randf() < 0.33:
					current_attitude = attitudes.fight
				else:
					current_attitude = attitudes.flee

		$AnimationPlayer.play("hit")
		var hits = $SFX/hits.get_children()
		var rand_hit = hits[randi()%$SFX/hits.get_child_count()]
		rand_hit.play()
		health -= damage * (1-damage_reduction[damage_type])
		if health <= 0:
			die()
		$HealthBar.set_value(health/max_health * 100)

func drop_key():
	Game.main.level.spawn_key(get_global_position())

func die():
	if state != states.dead:
		state = states.dead
		#$Sprites.hide()
		if randf() < 0.5:
			drop_key()

		$CollisionShape2D.call_deferred("set_disabled", true)

		$AnimationPlayer.play("die")
		$SFX/GhostDeath.play()
		death_timer.start()





func _on_DeathTimer_timeout():
	call_deferred("queue_free")


func _on_ScanTimer_timeout():
	saturate_sprite()
