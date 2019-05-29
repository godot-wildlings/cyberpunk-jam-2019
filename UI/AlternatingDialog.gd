extends CanvasLayer

onready var dialog_container = $MarginContainer/VBoxContainer/MarginContainer/DialogContainer
export var dialog : Array = []
export var exit_scene : PackedScene
var text_revealed : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	start()

func start():

	if exit_scene == null:
		exit_scene = preload("res://Levels/Level1.tscn")

	if dialog.size() == 0:
		dialog = [
			"........"
		]

	for i in range(dialog.size()):
		var new_panel = Label.new()
		new_panel.set_text(dialog[i])
		if i%2 == 0:
			new_panel.set_align(Label.ALIGN_RIGHT)
		else:
			new_panel.set_align(Label.ALIGN_LEFT)
		dialog_container.add_child(new_panel)




# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func next_tab():

	text_revealed = -1
	var next_tab = dialog_container.get_current_tab()+1
	if next_tab == dialog.size():
		next_scene()
	else:
		dialog_container.set_current_tab(next_tab)
		reveal_letter()

		$TextRevealTimer.start()
		if next_tab%2 == 0:
			$TextRevealNoise.set_pitch_scale(1.0)
		else:
			$TextRevealNoise.set_pitch_scale(0.8)
		$TextRevealNoise.play()

func next_scene():
	Game.main.switch_levels(exit_scene)

#warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		next_tab()
	elif Input.is_action_just_pressed("ui_cancel"):
		next_scene()

func _on_NextPageButton_pressed():
	next_tab()

func reveal_letter():
	text_revealed += 1
	dialog_container.get_child(dialog_container.get_current_tab()).set_visible_characters(text_revealed)
	if text_revealed >= dialog_container.get_child(dialog_container.get_current_tab()).get_text().length():
		$TextRevealNoise.stop()

func _on_TextRevealTimer_timeout():
	reveal_letter()
	$TextRevealTimer.start()