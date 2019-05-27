extends Node2D
var player : KinematicBody2D
var gun : Node2D
var tween : Tween

func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	player = get_parent().get_parent()
	gun = $Gun
	tween = player.get_node("Tween")


func use():
	# if there's someone in melee range, punch.
	# else, shoot gun.

	var melee_candidates = $MeleeRange.get_overlapping_bodies()
	if melee_candidates.size() > 0:
		punch()
	else:
		shoot()

func punch():
	print("punching")
	# change sprite to punching.
	# auto-hit nearby opponent
	player.animation_player.play("punch")

func shoot():
	draw_gun()
	yield(tween, "tween_completed")
	print("shooting")
	if player.ammo > 0:
		player.gun.shoot()
		player.ammo -= 1
		player.get_node("AmmoBar").set_value(player.ammo/player.max_ammo * 100)
	else:
		print("out of ammo")

	holster_gun()


func draw_gun():
	# should rotate the gun up
	gun.rotation = PI/2
	gun.show()


	tween.interpolate_property(gun, "rotation",
			PI/2, 0, 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func holster_gun():
	# should rotate the gun down.
	tween.interpolate_property(gun, "rotation",
			0, PI/2, 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	gun.hide()
