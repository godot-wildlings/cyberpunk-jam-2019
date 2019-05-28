extends Area2D

enum states { ready, collected }

var state = states.ready

func _ready():
	pass # Replace with function body.


func die():
	$Sprite.hide()
	state = states.collected
	call_deferred("queue_free")

func _on_Key_body_entered(body):
	if body == Game.player and state == states.ready:
		body.pickup_key()
		die()
