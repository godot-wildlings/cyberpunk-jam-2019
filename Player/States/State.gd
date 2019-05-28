extends Node2D

class_name Player_State

var player : KinematicBody2D

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

