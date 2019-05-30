extends Player_State

#var player : KinematicBody2D
var my_state_num : int
#var warning_issued : bool = false
onready var sprite : Sprite = get_node("EnteringSprite")

var object_entered # most likely a door


func _ready():
	player = get_parent().get_parent()
	call_deferred("deferred_ready")
	#warning-ignore:return_value_discarded
	$WaitToEnterTimer.connect("timeout", self, "_on_Timer_timeout")

func deferred_ready():
	my_state_num = player.states.entering
#	if not warning_issued:
#		push_warning("relying on animation_finished for state changes is dangerouns")
#		warning_issued = true
#	if not player.animation_player.is_connected("animation_finished", self, "_on_animation_finished"):
#		player.animation_player.connect("animation_finished", self, "_on_animation_finished")

#warning-ignore:unused_argument
func activate(arguments : Array = []):
	if arguments.size() > 0:
		object_entered = arguments[0]
	sprite.show()
	var vector_to_door = object_entered.get_global_position() - player.get_global_position()
	player.position.x += vector_to_door.x
	player.animation_player.play("enter")
	$WaitToEnterTimer.start()

func deactivate():
	#player.animation_player.disconnect("animation_finished", self, "_on_animation_finished")
	sprite.hide()

#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		velocity = Vector2.ZERO

#func _on_animation_finished(anim_name):
#
#	if anim_name == "enter":
#		player.set_state(player.states.hidden)

func _on_Timer_timeout():
	player.set_state(player.states.hidden)
	if player.currentlyIn && player.currentlyIn.has_method("close_door"):
		player.currentlyIn.close_door()
	if object_entered.has_method("actOnPlayer"):
		yield(object_entered, "animDone")
		object_entered.actOnPlayer()

func flip_sprites(dir):
	if dir > 0:
		sprite.set_flip_h(false)
	else:
		sprite.set_flip_h(true)