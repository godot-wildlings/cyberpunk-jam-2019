extends Node2D

var console : Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	console = get_parent()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#warning-ignore:unused_argument
func interact(interactor):
	console.get_node("AnimationPlayer").play("interact")
