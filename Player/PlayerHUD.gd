extends Container

# Declare member variables here. Examples:
#var action_labels : Array = []
onready var actions = $VBoxContainer/Actions
onready var action_description = $VBoxContainer/ActionDescription
onready var key_label = $Panel/NumKeys

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	#action_labels = $Actions.get_children()
	for action_num in Game.player.action_names.keys():
		var new_label = Label.new()
		actions.add_child(new_label)
		new_label.set_text(Game.player.action_names[action_num])
		#$Actions.get_child(action_num).set_text(Game.player.action_names[action_num])


#warning-ignore:unused_argument
func _process(delta):
	for label in actions.get_children():
		if label.get_position_in_parent() == Game.player.current_action_num:
			label.set_modulate(Color.magenta)
		else:
			label.set_modulate(Color.cyan)

	update_description_label()

	update_keys()


func update_description_label():
	action_description.set_text(Game.player.action_descriptions[Game.player.current_action_num])

func update_keys():
	key_label.set_text(str(Game.player.keys_held))
