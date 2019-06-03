extends Sprite

export var randomize_building : bool = true
export var randomize_y : bool = false
export var moving : bool = false
export var speed : float = 100.0
var direction : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	if randf()<.5:
		direction *= -1
	set_flip_h(direction<0)

	speed = rand_range(speed/2, speed * 2)

	if randomize_building:
		set_frame(randi()%(get_hframes()*get_vframes()))

	if randomize_y:
		position.y += rand_range(-200, 200)


func _process(delta):
	var extents = 3000
	if moving:
		position.x = wrapf(position.x + delta*speed*direction, -extents, extents )
