extends KinematicBody2D

# Declare member variables here. Examples:
var direction : int = 1
var speed : float = 80.0
export var damage_output_per_hit = 25

export (Game.damage_types) var melee_damage_type

onready var decision_timer = $DecisionTimer
onready var reload_timer = $ReloadTimer

enum states { initializing, ready, passive, alert, dead, frozen }
var state = states.initializing

enum melee_weapon_states { reloading, ready }
var melee_weapon_state = melee_weapon_states.reloading

# Called when the node enters the scene tree for the first time.
func _ready():
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



func _on_DecisionTimer_timeout():
	if randf() < 0.5:
		direction = 1
	else:
		direction = -1
	decision_timer.start()




func _on_ReloadTimer_timeout():
	melee_weapon_state = melee_weapon_states.ready


