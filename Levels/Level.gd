extends Node2D

onready var player_spawn : Position2D = $PlayerSpawn

enum states { initializing, running, paused, resetting }

var state = states.initializing
export var starting_cutscene : String


func _ready():
	state = states.running
	spawn_player()
	if starting_cutscene and starting_cutscene.length() > 0 and Game.main:
		Game.main.load_cutscene(starting_cutscene)

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
	if has_node("Collectibles"):
		$Collectibles.call_deferred("add_child", new_key)
	else:
		var new_node = Node2D.new()
		new_node.set_name("Collectibles")
		add_child(new_node)
		$Collectibles.call_deferred("add_child", new_key)

func stop_music():
	if has_node("BGMusic"):
		$BGMusic.stop()
