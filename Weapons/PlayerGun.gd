extends Node2D

export var bullet_scene : PackedScene
var shooter
var bullet_speed : float = 400.0

func _ready():

	call_deferred("deferred_ready")

func deferred_ready():
	shooter = Game.player

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func shoot():
	spawn_bullet()
	$AudioStreamPlayer2D.play()

func spawn_bullet():
	var new_bullet = bullet_scene.instance()
	$Bullets.add_child(new_bullet)
	new_bullet.set_as_toplevel(true)
	var rot = 0
	if shooter.get_direction() == -1:
		rot = PI
	new_bullet.start($Muzzle.get_global_position(), Vector2.RIGHT * shooter.direction * bullet_speed, rot)
