extends Node

# Declare member variables here. Examples:
var level_num : int = -1
var level : Node
onready var level_container : Node2D = $Levels
onready var cutscene_container : Node2D = $Cutscenes

var levels : Dictionary = {
		"intro" : load("res://Levels/Intro.tscn"),
		"PoorQuarter" : load("res://Levels/PoorQuarter.tscn"),
		"RichQuarter" : load("res://Levels/RichQuarter.tscn"),
		"Corporation" : load("res://Levels/Mazui-Hito-Fight.tscn")

		#"2" : preload("res://Levels/Level2.tscn")
}

var cutscenes : Dictionary = {
		"HQ1" : load("res://Story/HQ1.tscn"),
		"FemmeFatale" : load("res://Story/FemmeFatale.tscn"),
		"Doppleganger" : load("res://Story/Mazui-Hito.tscn")
}


onready var tween = get_node("Tween")


# Called when the node enters the scene tree for the first time.
func _ready():
	Game.main = self

	next_level()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func remove_level(level):
	if is_instance_valid(level):
		level_container.remove_child(level)
		level.call_deferred("queue_free")

func load_level_num(num : int):
	var level_scene = levels.values()[num]
	load_level(level_scene)

func switch_levels(level_tscn : PackedScene):
	remove_level(level)
	load_level(level_tscn)

func switch_levels_by_name(scene_name : String):
	remove_level(level)
	load_level_name(scene_name)

func load_level_name(level_name : String):
	var level_scene = levels[level_name]
	print(self.name, " load_level_name: ", level_name)
	print(level_scene)
	load_level(level_scene)

func load_level(level_scene : PackedScene):
	if level_scene != null:
		var new_level = level_scene.instance()
		level_container.add_child(new_level)
		level = new_level
	else:
		push_warning("problem loading scene")



func load_cutscene(cutscene_name : String):
	"""
	Cutscenes get loaded on top of the current scene, and the current scene gets paused.
	They just need to go away and unpause the game when they're completed.
	They don't need to load any new level.
	"""

	Game.player.HUD.hide()
	var new_cutscene = cutscenes[cutscene_name].instance()
	cutscene_container.add_child(new_cutscene)
	Game.pause()

func end_cutscene(cutscene_node):
	cutscene_container.remove_child(cutscene_node)
	Game.player.HUD.show()
	Game.resume()

func next_level():
	level_num = wrapi(level_num +1, 0, levels.size())
	if level != null:
		remove_level(level)
	load_level(levels.values()[level_num])

func fade_out():
	tween.interpolate_property($CanvasLayer/ColorRect, "modulate",
		Color(0,0,0,0), Color.white, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func fade_in():
	tween.interpolate_property($CanvasLayer/ColorRect, "modulate",
		Color.white, Color(0,0,0,0), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

func reset_level():
	fade_out()
	yield(tween, "tween_completed")
	if level != null:
		remove_child(level)
	fade_in()
	load_level_num(level_num)

func hover():
	var hover_noises = $HoverNoises.get_children()
	hover_noises[randi()%hover_noises.size()].play()

func click():
	$ClickNoise.play()
