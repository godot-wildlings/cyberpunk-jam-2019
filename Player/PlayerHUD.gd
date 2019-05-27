extends Container

# Declare member variables here. Examples:
var action_labels : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	action_labels = $Actions.get_children()
	for action_num in Game.player.action_names.keys():
		$Actions.get_child(action_num).set_text(Game.player.action_names[action_num])


#warning-ignore:unused_argument
func _process(delta):
	for label in action_labels:
		if label == action_labels[Game.player.current_action]:
			label.set_modulate(Color.magenta)
		else:
			label.set_modulate(Color.cyan)
