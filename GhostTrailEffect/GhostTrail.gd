extends Sprite

onready var alpha_tween : Tween = $AlphaTween

func _ready():
	#warning-ignore:return_value_discarded
	alpha_tween.connect("tween_completed", self, "_on_AlphaTween_tween_completed")
	#warning-ignore:return_value_discarded
	alpha_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), .6, Tween.TRANS_SINE, Tween.EASE_OUT)
	#warning-ignore:return_value_discarded
	alpha_tween.start()

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _on_AlphaTween_tween_completed(obj : Object, key : NodePath):
		queue_free()