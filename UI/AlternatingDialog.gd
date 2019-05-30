extends CanvasLayer

onready var dialog_container = $MarginContainer/VBoxContainer/MarginContainer/DialogContainer
export var dialog : Array = []

onready var next_button = $MarginContainer/VBoxContainer/NextPageButton
#export var exit_scene_name : String
#cutscenes always go back to the scene they were loaded from

var text_revealed : int = -1

var current_tab_num : int = -1

# Called when the node enters the scene tree for the first time.
func _ready():

	instantiate_tabs()
	next_button.hide()

	$MusicLeadTimer.start()

func instantiate_tabs():
	for i in range(dialog.size()):
		var new_panel = Label.new()
		new_panel.set_text(dialog[i])
		new_panel.set_visible_characters(0)
		if i%2 == 0:
			new_panel.set_align(Label.ALIGN_RIGHT)
		else:
			new_panel.set_align(Label.ALIGN_LEFT)
		dialog_container.add_child(new_panel)


func start():

#	if exit_scene_name == null:
#		exit_scene_name = "res://Levels/HQ1.tscn"

#	if dialog.size() == 0:
#		dialog = [
#			"........"
#		]

	dialog_container.set_current_tab(0)
	next_button.show()
	next_tab()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func next_tab():

	text_revealed = -1
	current_tab_num += 1
	#var next_tab = dialog_container.get_current_tab()+1
	if current_tab_num == dialog.size():
		end_cutscene()
	else:
		dialog_container.set_current_tab(current_tab_num)
		reveal_letter()

		$TextRevealTimer.start()
		if current_tab_num%2 == 0:
			$TextRevealNoiseRight.play()
		else:
			$TextRevealNoiseLeft.play()

func end_cutscene():
	Game.main.end_cutscene(self)

#warning-ignore:unused_argument
func _input(event):
	if Input.is_action_just_pressed("ui_accept"):
		next_tab()
	elif Input.is_action_just_pressed("ui_cancel"):
		end_cutscene()

func _on_NextPageButton_pressed():
	next_tab()
	Game.main.click()

func reveal_letter():

	text_revealed += 1
	dialog_container.get_child(current_tab_num).set_visible_characters(text_revealed)
	if text_revealed >= dialog_container.get_child(current_tab_num).get_text().length():
		$TextRevealNoiseLeft.stop()
		$TextRevealNoiseRight.stop()

func _on_TextRevealTimer_timeout():
	reveal_letter()
	$TextRevealTimer.start()

func _on_AnyButton_hover():
	Game.main.hover()



func _on_MusicLeadTimer_timeout():
	start()
