extends Node2D

onready var player_spawn : Position2D = $PlayerSpawn

enum states { initializing, running, paused, resetting }

var state = states.initializing
export var starting_cutscene : String


func _ready():
	state = states.running
	spawn_player()
	if starting_cutscene != null and starting_cutscene.length() > 0:
		Game.main.load_cutscene(starting_cutscene)

	spawn_background_buildings(60, "Far")
	spawn_background_buildings(30, "Med")



#warning-ignore:unused_argument
func _process(delta):
	update()

func spawn_background_buildings(number : int = 1, layer : String = "Far"):
		var building_container
		var scale_factor : float
		var modulate_factor : Color

		if layer == "Far":
			building_container = $CanvasLayer/ParallaxBackground/Far
			scale_factor = 0.5
			modulate_factor = Color.darkred
		elif layer == "Med":
			building_container = $CanvasLayer/ParallaxBackground/Med
			scale_factor = 0.75
			modulate_factor = Color.white
		elif layer == "Near":
			building_container = $CanvasLayer/ParallaxBackground/Near
			scale_factor = 1.0
			modulate_factor = Color.white + Color.lightgray



		var building_scene = preload("res://Scenery/BackgroundBuilding.tscn")
#		var y_component = $Floors.get_global_position().y
		var y_component = 400
		var x_extent = 2000
		for i in range(number):
			var new_building = building_scene.instance()
			building_container.add_child(new_building)
			new_building.set_global_position(Vector2(rand_range(-x_extent, x_extent), y_component))
			var rand_scale = Vector2.ONE * rand_range(0.5, 1.5)
			new_building.set_scale(rand_scale * scale_factor)
			new_building.set_self_modulate(modulate_factor)


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
