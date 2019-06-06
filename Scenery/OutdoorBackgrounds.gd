extends ParallaxBackground



func _ready():
	spawn_background_buildings(60, "Far", 0.5)
	spawn_background_buildings(30, "Med", 1.0)
	spawn_background_signs(30, "Far", 0.33)
	spawn_background_signs(20, "Med", 0.75)
	spawn_background_cars(15, "Near", 0.75)
	spawn_background_cars(35, "Med", 0.75)


func spawn_background_cars(number, distance, scale_factor):
	var object_scene = preload("res://Scenery/BackgroundCar.tscn")
	spawn_background_objects(number, object_scene, distance, scale_factor)


func spawn_background_buildings(number, distance, scale_factor):
	var object_scene = preload("res://Scenery/BackgroundBuilding.tscn")
	spawn_background_objects(number, object_scene, distance, scale_factor)

func spawn_background_signs(number, distance, scale_factor):
	var object_scene = preload("res://Scenery/BackgroundSign.tscn")
	spawn_background_objects(number, object_scene, distance, scale_factor)

func spawn_background_objects(number, object_scene, layer, scale_factor):
		var container

		var modulate_factor : Color
		var x_pos : float
		var y_pos : float

		if layer == "Far":
			container = find_node("Far")
		elif layer == "Med":
			container = find_node("Med")
		elif layer == "Near":
			container = find_node("Near")
		modulate_factor = Color.white * rand_range(0.1, 0.6)
		modulate_factor.a = 1.0

#		if has_node("Horizon_Marker"):
#			y_pos = container.get_node("Horizon_Marker").position.y
#		else:
#			y_pos = 0
		y_pos = 00 # WTF? I don't understand CanvasLayer coordinates.

		x_pos = -2000
		#warning-ignore:unused_local_variable
		for i in range(number):
			var new_object = object_scene.instance()
			container.add_child(new_object)
			new_object.set_global_position(Vector2(x_pos, y_pos))
			var rand_scale = Vector2.ONE * rand_range(0.5, 1.5)
			new_object.set_scale(rand_scale * scale_factor)
			new_object.set_modulate(modulate_factor)
			x_pos += rand_range(100.0, 400.0)
