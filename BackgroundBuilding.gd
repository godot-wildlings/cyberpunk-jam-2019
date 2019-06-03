extends Sprite

export var randomize_building : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	if randomize_building:
		set_frame(randi()%(get_hframes()*get_vframes()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
