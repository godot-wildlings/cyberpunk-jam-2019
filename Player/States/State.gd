extends Node2D

class_name Player_State

var player : KinematicBody2D
var velocity : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	player = Game.player


func state_process():
	pass

func show_sprites():
	for child in get_children():
		if child is Sprite:
			child.show()

func hide_sprites():
	for child in get_children():
		if child is Sprite:
			child.hide()

func get_velocity():
	return velocity

func set_velocity(vel : Vector2):
	velocity = vel

func get_gravity_vector(delta) -> Vector2:
	return Vector2(0, Game.gravity * delta)

func move_and_bounce(vel, delta, damping) -> Vector2:

	var collision = player.move_and_collide(vel * delta)
	var new_velocity : Vector2 = vel
	if collision:
		var reflect = collision.remainder.bounce(collision.normal)
		new_velocity = vel.bounce(collision.normal) * damping
		#warning-ignore:return_value_discarded
		player.move_and_collide(reflect)
	return new_velocity


func flip_sprites(dir):
	var sprites = player.get_node("PlayerSprites")
	var x_scale = sprites.get_scale().x
	var y_scale = sprites.get_scale().y
	if dir > 0:
		x_scale = abs(x_scale)
	else:
		x_scale = -1 * abs(x_scale)
	sprites.set_scale(Vector2(x_scale, y_scale))
