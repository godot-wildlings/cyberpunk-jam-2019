extends Node2D

export var bullet_scene : PackedScene
var shooter
var bullet_speed : float = 400.0

func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	shooter = get_parent()

func shoot(target : Node2D):
	spawn_bullet(target)
	play_shoot_sfx()

func play_shoot_sfx():
	randomize()
	var sfx_container = $SFX
	var sfx_options = sfx_container.get_children()
	var sfx_node = sfx_options[randi()%sfx_options.size()]
	sfx_node.play()

func spawn_bullet(target : Node2D):
	var new_bullet = bullet_scene.instance()
	$Bullets.add_child(new_bullet)
	new_bullet.set_as_toplevel(true)

	new_bullet.start($Muzzle.get_global_position(), Vector2.RIGHT * sign(target.global_position.x) * bullet_speed, 0, shooter)