extends Label

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#warning-ignore:unused_argument
func _process(delta):
	var my_pos = get_parent().get_global_position()
	set_text(str("%5.0f" % my_pos.x) + ", " + str("%5.0f" % my_pos.y))