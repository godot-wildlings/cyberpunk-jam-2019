extends Node2D

export var bullet_scene : PackedScene
var shooter
var bullet_speed : float = 400.0

enum states { ready, reloading }
var state = states.ready

func _ready():

	call_deferred("deferred_ready")

func deferred_ready():
	shooter = Game.player

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func shoot():
	if state == states.ready:
		spawn_bullet()
		play_shoot_sfx()
		state = states.reloading
		$ReloadTimer.start()
	else:
		pass


func play_shoot_sfx():
	randomize()
	var sfx_container = $SFX
	var sfx_options = sfx_container.get_children()
	var sfx_node = sfx_options[randi()%sfx_options.size()]
	sfx_node.play()

func spawn_bullet():
	var new_bullet = bullet_scene.instance()
	$Bullets.add_child(new_bullet)
	new_bullet.set_as_toplevel(true)
	var rot = 0
	if shooter.get_direction() == -1:
		rot = PI
	new_bullet.start($Muzzle.get_global_position(), Vector2.RIGHT * shooter.direction * bullet_speed, rot, shooter)



func _on_ReloadTimer_timeout():
	state = states.ready
