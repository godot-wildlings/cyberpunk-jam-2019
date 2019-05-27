extends Area2D

# Declare member variables here. Examples:
var speed : float = 400.0
var velocity
#var direction : int = 1
var ticks : int = 0
export (Game.damage_types) var damage_type = Game.damage_types.physical
export var damage : float = 25.0

enum states { active, dead }
var state = states.active

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(pos, vel, rot):
	set_as_toplevel(true)
	set_global_position(pos)
	velocity = vel
	speed = vel.length()
	set_global_rotation(rot)
	$AnimationPlayer.play("shoot") # muzzle flash

func _process(delta):
	ticks += 1
	if ticks > 1:
		set_global_position(get_global_position() + velocity * delta)

func die():
	call_deferred("queue_free")

func _on_Bullet_body_entered(body):
	if ticks > 1 and state == states.active:
		if body.has_method("hit"):
			body.hit(damage, damage_type)
			state = states.dead
			die()
		else: # hit a wall
			$ThudNoise.play()
			$Sprite.hide()
			yield($ThudNoise, "finished")
			die()
