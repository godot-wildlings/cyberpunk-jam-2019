extends KinematicBody2D

# Declare member variables here. Examples:
var direction : int = 1
var speed : float = 80.0
export var damage_output_per_hit = 25

export (Game.damage_types) var melee_damage_type

onready var decision_timer : Timer = $DecisionTimer
onready var reload_timer : Timer = $ReloadTimer
onready var ghost_timer : Timer = $GhostTimer
onready var ghost_tscn : PackedScene = preload("res://Ghost/Ghost.tscn") as PackedScene

enum states { initializing, ready, passive, alert, dead, frozen }
var state = states.initializing

enum melee_weapon_states { reloading, ready }
var melee_weapon_state = melee_weapon_states.reloading

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

# Called when the node enters the scene tree for the first time.
func _ready():
	ghost_timer.connect("timeout", self, "_on_GhostTimer_timout")
	decision_timer.start()
	reload_timer.start()
	state = states.passive


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var collision = move_and_collide(Vector2.RIGHT * direction * speed * delta)
	if melee_weapon_state == melee_weapon_states.ready and collision != null:
		var collider = collision.get_collider()
		if collider == Game.player:
			melee_attack(collider)

func melee_attack(object):
	if object.has_method("hit"):
		object.hit(damage_output_per_hit, melee_damage_type)
		melee_weapon_state = melee_weapon_states.reloading
		reload_timer.start()


func _on_GhostTimer_timout():
	var ghost_instance : Node2D = ghost_tscn.instance()
	get_parent().add_child(ghost_instance)
	ghost_instance.position = position
	ghost_instance.texture = $Sprite.texture
	ghost_instance.frame = $Sprite.frame
	ghost_instance.rotation = $Sprite.rotation
	ghost_instance.flip_h = $Sprite.flip_h
	

func _on_DecisionTimer_timeout():
	if randf() < 0.5:
		direction = 1
	else:
		direction = -1
	decision_timer.start()




func _on_ReloadTimer_timeout():
	melee_weapon_state = melee_weapon_states.ready

func hit(damage, damage_type):
	$AnimationPlayer.play("hit")
	var hits = $SFX/hits.get_children()
	var rand_hit = hits[randi()%$SFX/hits.get_child_count()]
	rand_hit.play()
	health -= damage * (1-damage_reduction[damage_type])
	if health <= 0:
		die()

func die():
	state = states.dead

	$AnimationPlayer.play("die")
	yield($AnimationPlayer, "animation_finished")

	call_deferred("queue_free")

