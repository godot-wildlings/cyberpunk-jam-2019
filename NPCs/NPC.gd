extends KinematicBody2D

onready var decision_timer : Timer = $DecisionTimer
onready var reload_timer : Timer = $ReloadTimer
onready var ghost_timer : Timer = $GhostTimer
onready var shot_timer : Timer = $ShotTimer
onready var ghost_tscn : PackedScene = preload("res://GhostTrailEffect/GhostTrail.tscn") as PackedScene
onready var gun : Node2D = $EnemyGun

enum attitudes { ignore, fight, flee }
enum attack_types { ranged, melee }
#export var friendly : bool = true
export (attitudes) var initial_attitude = attitudes.ignore
export (attitudes) var scanned_attitude = attitudes.fight
export (attack_types) var attack_type = attack_types.melee
export var damage_output_per_hit = 25
export (Game.damage_types) var melee_damage_type

var direction : int = 1
var speed : float = 80.0
var scanned : bool = false
var can_shoot : bool = true

var current_sprite

enum states { initializing, ready, passive, alert, dead, frozen }
var state = states.initializing

enum weapon_states { reloading, ready }
var melee_weapon_state = weapon_states.reloading
var ranged_weapon_state = weapon_states.reloading

export var max_health : float = 50.0
var health : float = max_health

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
	#warning-ignore:return_value_discarded
	ghost_timer.connect("timeout", self, "_on_GhostTimer_timeout")
	#warning-ignore:return_value_discarded	
	shot_timer.connect("timeout", self, "_on_ShotTimer_timeout")
	decision_timer.start()
	reload_timer.start()
	state = states.passive
	current_sprite = $Sprites/RealSprite
	$AnimationPlayer.play("walk")
	gun.visible = false

	call_deferred("deferred_ready")

func deferred_ready():
	if initial_attitude == attitudes.fight:
		enable_collisions_with_player()

func enable_collisions_with_player():
	var player_bit = 0
	var player_value = 1
	set_collision_mask_bit(player_bit, player_value)


func _process(delta):

	var collision = move_and_collide(Vector2.RIGHT * direction * speed * delta)

	var current_attitude
	if scanned == false:
		current_attitude = initial_attitude
	else:
		current_attitude = scanned_attitude

	if Game.ticks%30 == 0:
		print(self.name, " current_attitude == ", current_attitude)

	if current_attitude == attitudes.fight:
		if attack_type == attack_types.melee:
			if melee_weapon_state == weapon_states.ready and collision != null:
				print(self.name, " attacking")
				var collider = collision.get_collider()
				if collider == Game.player:
					melee_attack(collider)
		elif attack_type == attack_types.ranged:
			gun.visible = true
			for body in $LineOfSight.get_overlapping_bodies():
				if body == Game.player and can_shoot:
					shoot(body)
	elif current_attitude == attitudes.flee:
		if Game.ticks %60 == 0:
			print(self.name, " is running away")
		if not warning_issued:
			push_warning("NPCs still need fleeing behaviour")
			warning_issued = true

func melee_attack(object):
	if object.has_method("hit"):
		object.hit(damage_output_per_hit, melee_damage_type)
		melee_weapon_state = weapon_states.reloading
		reload_timer.start()

func shoot(target):
	assert is_instance_valid(gun)
	if gun.has_method("shoot"):
		gun.shoot(target)
		can_shoot = false
		shot_timer.start()
		

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

func _on_DecisionTimer_timeout():
	if randf() < 0.5:
		direction = 1
		$Sprites/RealSprite.set_flip_h(false)
	else:
		direction = -1
		$Sprites/RealSprite.set_flip_h(true)

	decision_timer.start()

func _on_ReloadTimer_timeout():
	melee_weapon_state = weapon_states.ready

func _on_ShotTimer_timeout():
	can_shoot = true

func _on_Player_scanned():
	$Sprites/RealSprite.hide()
	$Sprites/VRSprite.show()
	current_sprite = $Sprites/VRSprite
	$GhostTimer.start()
	print(self.name, " scanned")
	scanned = true
	if scanned_attitude == attitudes.fight:
		enable_collisions_with_player()

func hit(damage, damage_type):
	if state != states.dead:
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
		if randf() < 1:
			drop_key()

		state = states.dead

		$AnimationPlayer.play("die")
		yield($AnimationPlayer, "animation_finished")

		call_deferred("queue_free")

