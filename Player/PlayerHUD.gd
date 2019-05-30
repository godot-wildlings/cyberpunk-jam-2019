extends Control

onready var key_label = $VBoxContainer/NumKeys

func _ready():
	$VBoxContainer/FullscreenToggle.set_tooltip("fullscreen")

#warning-ignore:unused_argument
func _process(delta):
	update_keys()


func update_keys():
	key_label.set_text(str(Game.player.keys_held))






func _on_FullscreenToggle_toggled(button_pressed):
	OS.set_window_fullscreen(button_pressed)
