extends Node

#warning-ignore:unused_class_variable
var main : Node
#warning-ignore:unused_class_variable
var level : Node2D
#warning-ignore:unused_class_variable
var player : KinematicBody2D


enum damage_types {
	physical,
	fire,
	electrical,
	acid,
	poison,
	cold
}

var damage_type_names : Dictionary = {
	damage_types.physical : "physical",
	damage_types.fire : "fire",
	damage_types.electrical : "electrical",
	damage_types.acid : "acid",
	damage_types.poison : "poison",
	damage_types.cold : "cold"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
