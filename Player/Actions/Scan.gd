extends Node2D

func _ready():
	pass

func deferred_ready():
	pass


func use():
	print("scanning")

	var candidates = $EffectiveRange.get_overlapping_areas()
	candidates += $EffectiveRange.get_overlapping_bodies()

	for candidate in candidates:
		if candidate.has_method("_on_Player_scanned"):
			candidate._on_Player_scanned()
