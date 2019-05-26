extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use():
	# get list of locked items inside effective range, then unlock them
	# is there ammo? collect keys somewhere?

	var candidates = $EffectiveRange.get_overlapping_areas()
	for candidate in candidates:
		if candidate.get_property_list().has("locked"):
			if candidate.locked == true:
				if candidate.has_method("unlock"):
					candidate.unlock()
				else:
					candidate.locked = false
