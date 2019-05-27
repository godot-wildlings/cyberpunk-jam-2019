"""
Doors should open, close, lock, unlock
Players can enter doors and return from doors
Some doors act as elevators
Some doors replenish supplies (health, ammo)
Some doors transition to a new scene or cutscene
"""

extends Node2D

enum door_types {
	ammo,
	health,
	portal,
	cutscene,
	shortcut,
	tutorial
}

var door_names : Dictionary = {
	door_types.ammo : "Guns",
	door_types.health : "Medical",
	door_types.portal : "101",
	door_types.cutscene : "303",
	door_types.shortcut : "Transit",
	door_types.tutorial : "press\nup"
}

export (door_types) var door_type = door_types.health
export var amount : float = 100
export var scene : PackedScene

onready var door : Area2D
var animation_player : AnimationPlayer


func _ready():
	door = get_parent()
	animation_player = door.get_node("AnimationPlayer")

func get_name() -> String:
	return door_names[door_type]


func interact(interactor):
	if not door.locked and not door.open:
		provide_reward(interactor)
		if animation_player.has_animation("open"):
			animation_player.play("open")
			door.open = true
	elif door.locked:
		if animation_player.has_animation("access_denied"):
			animation_player.play("access_denied")
	elif door.open:
		# what should happen? The door is already open
		pass



func animate():
	"""
	First, animate the doors opening, then animate the player walking in
	"""


func provide_reward(interactor):
	if door_type == door_types.ammo and interactor.has_method("add_ammo"):
		interactor.add_ammo(amount)

	elif door_type == door_types.health and interactor.has_method("recover_health"):
		interactor.recover_health(amount)

	elif door_type == door_types.cutscene:
		Game.main.load_cutscene(scene)

	elif door_type == door_types.portal:
		Game.main.load_level(scene)

	elif door_type == door_types.shortcut:
		Game.player.set_global_position(door.get_node("exit").get_global_position())



