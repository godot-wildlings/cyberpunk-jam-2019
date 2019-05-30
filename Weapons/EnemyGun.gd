extends Node2D

export var bullet_scene : PackedScene
var shooter
var bullet_speed : float = 400.0
onready var shot_noise : AudioStreamPlayer2D = $SFX/Gunshot

func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	shooter = get_parent()
	if shooter.character_type == shooter.character_types.sinner:
		bullet_scene = preload("res://Projectiles/NPCLaser.tscn")
		shot_noise = $SFX/Laser2
func shoot(target : Node2D):
	spawn_bullet(target)
	play_shoot_sfx()

func play_shoot_sfx():

	shot_noise.play()





func spawn_bullet(target : Node2D):
	var new_bullet = bullet_scene.instance()
	$Bullets.add_child(new_bullet)
	new_bullet.set_as_toplevel(true)
	var direction = sign((target.global_position - global_position).x)
	var rot = 0
	if target.get_direction() == -1:
		rot = PI
	new_bullet.start($Muzzle.get_global_position(), Vector2.RIGHT * direction * bullet_speed, rot, shooter)