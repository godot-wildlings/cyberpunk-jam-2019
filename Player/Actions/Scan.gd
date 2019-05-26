extends Node2D

signal scanned()

# Called when the node enters the scene tree for the first time.
func _ready():
	call_deferred("deferred_ready")

func deferred_ready():
	var err = connect("scanned", Game.main.level, "_on_Player_scanned")
	if err:
		push_warning(self.name + " having trouble connecting signals")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func use():
	print("scanning")
	emit_signal("scanned")