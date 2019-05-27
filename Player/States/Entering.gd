extends Node2D


var player : KinematicBody2D
var my_state_num : int
var warning_issued : bool = false

func _ready():
	player = get_parent().get_parent()
	call_deferred("deferred_ready")

func deferred_ready():
	my_state_num = player.states.entering
	if not warning_issued:
		push_warning("relying on animation_finished for state changes is dangerouns")
		warning_issued = true
	if not player.animation_player.is_connected("animation_finished", self, "_on_animation_finished"):
		player.animation_player.connect("animation_finished", self, "_on_animation_finished")

#warning-ignore:unused_argument
func activate(arguments : Array = []):
	$EnteringSprite.show()
	player.animation_player.play("enter")

func deactivate():
	player.animation_player.disconnect("animation_finished", self, "_on_animation_finished")
	$EnteringSprite.hide()

#warning-ignore:unused_argument
func process_state(delta):
	if player.state == my_state_num:
		pass

func _on_animation_finished(anim_name):

	if anim_name == "enter":
		player.set_state(player.states.hidden)
