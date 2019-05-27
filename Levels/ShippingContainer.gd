extends StaticBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_colors = [Color.darkblue, Color.darkgreen, Color.darkgoldenrod, Color.darkkhaki, Color.darkorange]
	$Sprite.set_self_modulate(rand_colors[randi()%rand_colors.size()])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
