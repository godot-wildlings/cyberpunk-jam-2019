extends StaticBody2D

var last_iReal_check : bool
var my_color : Color

# Called when the node enters the scene tree for the first time.
func _ready():
	var rand_colors = [Color.darkblue, Color.darkgreen, Color.darkgoldenrod, Color.darkkhaki, Color.darkorange]
	my_color = rand_colors[randi()%rand_colors.size()]
	desaturate(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Game.ticks % 20 == 0:
		if Game.player.iReal_active != last_iReal_check:
			desaturate(Game.player.iReal_active)
			last_iReal_check = Game.player.iReal_active

func desaturate(toggle):
	if toggle == true:
		$Sprite.set_self_modulate(Color.white)
	else:
		$Sprite.set_self_modulate(my_color)
