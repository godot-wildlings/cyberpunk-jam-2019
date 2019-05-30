extends Node

#warning-ignore:unused_class_variable
var main : Node
#warning-ignore:unused_class_variable
var level : Node2D
#warning-ignore:unused_class_variable
var player : KinematicBody2D
#warning-ignore:unused_class_variable
var gravity : float = 500.0
#warning-ignore:unused_class_variable
var time_elapsed : float = 0.0
#warning-ignore:unused_class_variable
var ticks : int = 0

enum damage_types {
	physical,
	fire,
	electrical,
	acid,
	poison,
	cold
}

#warning-ignore:unused_class_variable
var damage_type_names : Dictionary = {
	damage_types.physical : "physical",
	damage_types.fire : "fire",
	damage_types.electrical : "electrical",
	damage_types.acid : "acid",
	damage_types.poison : "poison",
	damage_types.cold : "cold"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time_elapsed += delta
	ticks += 1

func play_random_sfx(container : Node2D):
	if is_instance_valid(container):
		var sfx_count : int = container.get_child_count()
		var rnd_sfx_idx : int = randi() % sfx_count
		var sfx_audio_player : AudioStreamPlayer2D = container.get_child(rnd_sfx_idx)
		if is_instance_valid(sfx_audio_player):
			if not sfx_audio_player.playing:
				sfx_audio_player.play()

func pause():
	get_tree().set_pause(true)

func resume():
	get_tree().set_pause(false)