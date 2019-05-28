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

var shooter

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(pos, vel, rot, gun_owner):
	set_as_toplevel(true)
	set_global_position(pos)
	velocity = vel
	speed = vel.length()
	set_global_rotation(rot)
	$AnimationPlayer.play("shoot") # muzzle flash
	shooter = gun_owner

func _process(delta):
	ticks += 1
	if ticks > 1: # muzzle flash hack. stay still for one frame, then move
		set_global_position(get_global_position() + velocity * delta)

func die():
	call_deferred("queue_free")

func _on_Bullet_body_entered(body):
	if state == states.active and body != shooter:
		if body.has_method("hit"):
			body.hit(damage, damage_type)
			state = states.dead
			die()
		else: # hit a wall
			$ThudNoise.play()
			$Sprite.hide()
			yield($ThudNoise, "finished")
			die()


func _on_DurationTimer_timeout():
	die()
