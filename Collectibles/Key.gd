extends Area2D

enum states { ready, collected }

var state = states.ready

func _ready():
	print("new key")
	pass # Replace with function body.


func die():
	$Sprite.hide()
	call_deferred("queue_free")

func start(new_position):
	set_global_position(new_position)

func _on_Key_body_entered(body):
	if body == Game.player and state == states.ready:
		state = states.collected
		$Sprite.hide()
		body.pickup_key()
		$PickupNoise.play()
		yield($PickupNoise, "finished")
		die()
