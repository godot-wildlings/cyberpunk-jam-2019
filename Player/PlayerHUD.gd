extends Container

onready var key_label = $VBoxContainer/NumKeys


#warning-ignore:unused_argument
func _process(delta):
	update_keys()


func update_keys():
	key_label.set_text(str(Game.player.keys_held))
