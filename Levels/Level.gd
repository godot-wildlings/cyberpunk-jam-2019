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
	spawn_background_signs(30, "Far")
	spawn_background_signs(20, "Med")
	spawn_background_cars(15, "Near")
	spawn_background_cars(35, "Med")

#warning-ignore:unused_argument
func _process(delta):
	update()

func spawn_background_cars(number, distance):
	var object_scene = preload("res://Scenery/BackgroundCar.tscn")
	spawn_background_objects(number, object_scene, distance)


func spawn_background_buildings(number, distance):
	var object_scene = preload("res://Scenery/BackgroundBuilding.tscn")
	spawn_background_objects(number, object_scene, distance)

func spawn_background_signs(number, distance):
	var object_scene = preload("res://Scenery/BackgroundSign.tscn")
	spawn_background_objects(number, object_scene, distance)

func spawn_background_objects(number, object_scene, layer):
		var container
		var scale_factor : float
		var modulate_factor : Color
		var x_pos : float
		var y_pos : float

		if layer == "Far":
			container = $CanvasLayer/ParallaxBackground/Far
			scale_factor = 0.5
		elif layer == "Med":
			container = $CanvasLayer/ParallaxBackground/Med
			scale_factor = 1.0
		elif layer == "Near":
			container = $CanvasLayer/ParallaxBackground/Near
			scale_factor = 2.0
		modulate_factor = Color.white * rand_range(0.1, 0.6)
		modulate_factor.a = 1.0
		y_pos = container.get_node("Horizon_Marker").get_global_position().y

		x_pos = -2000
		for i in range(number):
			var new_object = object_scene.instance()
			container.add_child(new_object)
			new_object.set_global_position(Vector2(x_pos, y_pos))
			var rand_scale = Vector2.ONE * rand_range(0.5, 1.5)
			new_object.set_scale(rand_scale * scale_factor)
			new_object.set_modulate(modulate_factor)
			x_pos += rand_range(100.0, 400.0)




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
