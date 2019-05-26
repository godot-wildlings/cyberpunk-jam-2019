extends Sprite

onready var alpha_tween : Tween = $AlphaTween

func _ready():
	alpha_tween.connect("tween_completed", self, "_on_AlphaTween_tween_completed")
	alpha_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .6, Tween.TRANS_SINE, Tween.EASE_OUT)
	alpha_tween.start()

func _on_AlphaTween_tween_completed(obj : Object, key : int):
		queue_free()