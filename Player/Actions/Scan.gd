extends Node2D

var player : KinematicBody2D

func _ready():
	$DurationTimer.connect("timeout", self, "_on_DurationTimer_timeout")
	call_deferred("deferred_ready")

func deferred_ready():
	player = get_parent().get_parent()


func use():
	print("scanning")

	var candidates = $EffectiveRange.get_overlapping_areas()
	candidates += $EffectiveRange.get_overlapping_bodies()

	for candidate in candidates:
		if candidate.has_method("_on_Player_scanned"):
			candidate._on_Player_scanned()

	player.iReal_active = true
	$DurationTimer.start()

func _on_DurationTimer_timeout():
	player.iReal_active = false