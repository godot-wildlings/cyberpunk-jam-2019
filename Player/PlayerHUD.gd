extends Container

# Declare member variables here. Examples:
var action_labels : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	action_labels = $Actions.get_children()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for label in action_labels:
		if label == action_labels[Game.player.current_action]:
			label.set_modulate(Color.magenta)
		else:
			label.set_modulate(Color.cyan)