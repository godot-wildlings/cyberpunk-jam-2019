extends Node

# Declare member variables here. Examples:
var level_num : int = -1
var level : Node2D
onready var level_container : Node2D = $Levels

var levels : Dictionary = {
		"1" : preload("res://Levels/Level1.tscn"),
		"2" : preload("res://Levels/Level2.tscn")
}




# Called when the node enters the scene tree for the first time.
func _ready():
	Game.main = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func remove_level(level):
	level_container.remove_child(level)
	level.call_deferred("queue_free")

func load_level_num(num : int):
	var level_scene = levels.values()[num]
	load_level(level_scene)

func load_level_name(level_name : String):
	var level_scene = levels[level_name]
	load_level(level_scene)

func load_level(level_scene : PackedScene):
	var new_level = level_scene.instance()
	level_container.add_child(new_level)
	level = new_level




func next_level():
	level_num = wrapi(level_num +1, 0, levels.size())
	if level != null:
		remove_level(level)
	load_level(levels.values()[level_num])

func reset_level():
	var tween = get_node("Tween")
	tween.interpolate_property($CanvasLayer/ColorRect, "modulate",
		Color(0,0,0,0), Color.white, 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property($CanvasLayer/ColorRect, "modulate",
		Color.white, Color(0,0,0,0), 0.5,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


	remove_child(level)
	load_level_num(level_num)
