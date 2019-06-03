extends Camera2D

# Declare member variables here. Examples:

#warning-ignore:unused_class_variable
var target = null
var DesiredZoom = Vector2(6, 6)
var Ticks :int = 0
var MinZoom = 0.3
var MaxZoom = 25.0

func _ready():
	DesiredZoom = zoom

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Ticks += 1

#	update()
#
#	if target != null:
#		position = target.position
#	else:
#		target = global.getPlayerShip()


	zoom = lerp(zoom, DesiredZoom, 0.2 * delta * 60)
	#print("zoom: ", str(zoom))

func _draw():
	#draw_string(global.BaseFont, Vector2(0, 20), "zoom: " + str(zoom), Color.antiquewhite )
	pass

func _input(event):
	if event is InputEventMouseButton and event.is_action("zoom_in"):
		DesiredZoom = zoom * 0.8
	if event is InputEventMouseButton and event.is_action("zoom_out"):
		DesiredZoom = zoom * 1.25

	DesiredZoom.x = clamp(DesiredZoom.x, MinZoom, MaxZoom)
	DesiredZoom.y = clamp(DesiredZoom.y, MinZoom, MaxZoom)

#func _run_death_cam():
#
#	tween.interpolate_property(self, "zoom",Vector2(), Vector2(0.3,0.3), 1,Tween.TRANS_LINEAR, Tween.EASE_OUT)
#
#	tween.start()