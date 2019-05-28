extends Node2D

onready var player_spawn : Position2D = $PlayerSpawn

enum states { initializing, running, paused, resetting }

var state = states.initializing


func _ready():
	state = states.running
	spawn_player()

#warning-ignore:unused_argument
func _process(delta):
	update()

func spawn_player():
	assert is_instance_valid(player_spawn)
	var player_scene = preload("res://Player/Player.tscn")
	var new_player = player_scene.instance()
	new_player.set_global_position(player_spawn.get_global_position())
	add_child(new_player)

func _on_ResetArea_body_entered(body):
	if body == Game.player:
		state = states.resetting
		update()
		Game.main.reset_level()

func spawn_key(location):
	var key_scene = preload("res://Collectibles/Key.tscn")
	var new_key = key_scene.instance()
	new_key.set_global_position(location)
	$Collectibles.add_child(new_key)
