extends Area2D

enum states { ready, collected }

var state = states.ready

func _ready():
	pass # Replace with function body.


func die():
	$Sprite.hide()
	call_deferred("queue_free")

func _on_Key_body_entered(body):
	if body == Game.player and state == states.ready:
		state = states.collected
		body.pickup_key()
		$PickupNoise.play()
		yield($PickupNoise, "finished")
		die()
