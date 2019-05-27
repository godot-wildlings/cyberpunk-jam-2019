extends Node2D

enum states { initializing, running, paused, resetting }
var state = states.initializing

# Called when the node enters the scene tree for the first time.
func _ready():
	state = states.running
	spawn_player()

# warning-ignore:unused_argument
func _process(delta):
	update()


func spawn_player():
	var player_scene = preload("res://Player/Player.tscn")
	var new_player = player_scene.instance()
	new_player.set_global_position($PlayerSpawn.get_global_position())
	add_child(new_player)



func _on_ResetArea_body_entered(body):
	if body == Game.player:
		state = states.resetting
		update()
		Game.main.reset_level()




