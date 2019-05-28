extends Node2D

var level
var containers_to_scan : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	level = get_parent()
	containers_to_scan = [level.get_node("Floors"), level.get_node("Crates")]

#warning-ignore:unused_argument
func _process(delta):
	update()

func draw_collision_shape(collision_shape : CollisionShape2D):
	var shape = collision_shape.get_shape()
	var shape_pos = collision_shape.get_global_position()
	if shape is RectangleShape2D:
		var top_left:Vector2 = shape_pos - shape.extents
		var top_right:Vector2 = top_left + Vector2.RIGHT * shape.extents.x * 2
		var bottom_left:Vector2 = top_left + Vector2.DOWN * shape.extents.y * 2
		var bottom_right:Vector2 = bottom_left + Vector2.RIGHT * shape.extents.x * 2
		var corner_radius:float = 16.0

		# top line
		draw_line(top_left + Vector2.RIGHT*corner_radius, top_right + Vector2.LEFT*corner_radius , Color.cyan, 3.0, true )
		# left wall
		draw_line(top_left + Vector2.DOWN*corner_radius, bottom_left, Color.cyan, 3.0, true)
		# right wall
		draw_line(top_right + Vector2.DOWN*corner_radius, bottom_right, Color.cyan, 3.0, true)
		draw_corner(16, top_left, "top_left")
		draw_corner(16, top_right, "top_right")

func draw_corner(radius, origin, type):
	var initial_rot : float
	var rotations : Dictionary = {
			"top_left":PI,
			"top_right":1.5*PI,
			"bottom_right":0,
			"bottom_left":PI/2
	}

	var offsets : Dictionary = {
			"top_left":Vector2(1,1)*radius,
			"top_right":Vector2(-1,1)*radius,
			"bottom_right":Vector2(-1,-1)*radius,
			"bottom_left":Vector2(1,-1)*radius
	}

	initial_rot = rotations[type]

	var num_steps : int = 4
	var corner_points : Array = []
	var step_rot = PI/2/num_steps
	for i in (num_steps + 1):
		var point = origin + offsets[type] + (Vector2.RIGHT*radius).rotated(initial_rot + i * step_rot)
		corner_points.push_back(point)
	draw_polyline(corner_points, Color.cyan, 3.0, true)


func draw_all_static_bodies(container_node):
	for child in container_node.get_children():
		if child is StaticBody2D:
			for grandchild in child.get_children():
				if grandchild is CollisionShape2D:
					draw_collision_shape(grandchild)


func _draw():
	if level.state == level.states.running:
		if Game.player.iReal_active:
			for container in containers_to_scan:
				draw_all_static_bodies(container)
