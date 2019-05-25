extends Area2D

signal player_entered(body)
signal player_exited(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	if Game.player != null and Game.player.has_method("_on_InteractiveObject_player_entered"):
		#warning-ignore:return_value_discarded
		connect("player_entered", Game.player, "_on_InteractiveObject_player_entered")
		#warning-ignore:return_value_discarded
		connect("player_exited", Game.player, "_on_InteractiveObject_player_exited")
	else:
		push_error("Interactive object is trying to connect to Game.player object, but can't.")



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Console_body_entered(body):
	if body == Game.player:
		emit_signal("player_entered", self)

func _on_Console_body_exited(body):
	if body == Game.player:
		emit_signal("player_exited", self)


#warning-ignore:unused_argument
func interact(who_called):
	$AnimationPlayer.play("interact")


