extends Node2D
var player : KinematicBody2D
var gun : Node2D
var tween : Tween
var initial_punch_sprite_scale
export var punch_damage : float = 10

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
		punch(melee_candidates)
	else:
		shoot()

func punch(punch_targets):
	print("punching")
	# change sprite to punching.
	# auto-hit nearby opponent
#	$PunchSprite.scale = initial_punch_sprite_scale
#	$PunchSprite.scale.x *= player.get_direction()
	player.animation_player.play("punch")

	for target in punch_targets:
		if target.has_method("hit"):
			target.hit(punch_damage, Game.damage_types.physical)

func shoot():
	gun.scale.x = abs(gun.scale.x) * player.get_direction()
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
	gun.rotation = -PI/2 * player.get_direction()
	gun.show()

	#warning-ignore:return_value_discarded
	tween.interpolate_property(gun, "rotation",
			null, 0, 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#warning-ignore:return_value_discarded
	tween.start()

func holster_gun():
	#warning-ignore:return_value_discarded
	tween.interpolate_property(gun, "rotation",
			null, -PI/2 * player.get_direction(), 0.2,
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	#warning-ignore:return_value_discarded
	tween.start()
	yield(tween, "tween_completed")
	gun.hide()
