extends Node2D

enum door_types {
	ammo,
	health,
	portal,
	cutscene,
	shortcut
}

var door_names : Dictionary = {
	door_types.ammo : "Guns",
	door_types.health : "Medical",
	door_types.portal : "101",
	door_types.cutscene : "303",
	door_types.shortcut : "Transit"
}

export (door_types) var door_type = door_types.health
export var amount : float = 100
export var scene : PackedScene

onready var door : Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	door = get_parent()

func get_name() -> String:
	return door_names[door_type]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func interact(interactor):
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



