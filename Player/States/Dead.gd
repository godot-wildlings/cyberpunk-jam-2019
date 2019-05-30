extends Player_State

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var alreadyTimedOut = false
# Called when the node enters the scene tree for the first time.
func _ready():
	$DeadSprite.visible = false
	$Timer.connect("timeout", self, "_on_Timer_timeout")
	$Timer2.connect("timeout", self, "reload") # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func activate():
	$Timer.start()

	#hardcore
	for other_state in get_parent().get_children():
		if other_state.name != self.name:
			get_parent().remove_child(other_state)

	for other_part in get_parent().get_parent().get_children():
		if other_part.name != get_parent().name and other_part.name != "Camera2D":
			get_parent().get_parent().remove_child(other_part)


func _on_Timer_timeout():

	$CrouchingSprite.visible = false
	$DeadSprite.visible = true
	$Timer.stop()
	$Timer2.start()

func reload():
	Game.main.switch_levels_by_name("Death")