extends Container

onready var loop_container = $Tracks

var current_song_index : int = -1

var current_loop_container : Node

signal song_changed(song_name)

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	set_volume(-22)


func set_volume(vol):
	for loop in loop_container.get_children():
		if loop.has_method("set_volume_db"):
			loop.set_volume_db(vol)


func stop_all_songs():
	Game.main.level.stop_music()

	for loop_container in get_children():
		for loop in loop_container.get_children():
			if loop.has_method("stop"):
					loop.stop()

func play_song(index_num):
	stop_all_songs()
	var num_songs = loop_container.get_child_count()
	var track_num = wrapi(index_num, 0, num_songs)
	var audio_player_node = loop_container.get_child(track_num)
	audio_player_node.play()
	current_song_index = track_num
	$TrackName.set_text(str(audio_player_node.name))
	return str(audio_player_node.name)


func play_next_song() -> String:
	return play_song(current_song_index + 1)

func play_current_song() -> String:
	return play_song(current_song_index)

func play_last_song() -> String:
	return play_song(current_song_index - 1)


func play_random_loop() -> String:
	var track_num = randi()%current_loop_container.get_child_count()
	return play_song(track_num)


func _on_BGMusicLoop_finished() -> void:
	var song_name = play_random_loop()
	emit_signal("song_changed", song_name)

#warning-ignore:return_value_discarded
func pause():
	stop_all_songs()

func _on_VolumeSlider_value_changed(value : float):
	var ratio = clamp(value/100, 0, 1.0)
	AudioServer.set_bus_volume_db(1, ( (log(ratio) * 20) + 7))
	$HBoxContainer/VolumeDisplay.set_value(value)
	print(self.name, " bus 1 vol == " , AudioServer.get_bus_volume_db(1))

#warning-ignore:return_value_discarded
func _on_PrevButton_pressed():
	play_last_song()

#warning-ignore:return_value_discarded
func _on_PlayButton_pressed():
	play_current_song()



#warning-ignore:return_value_discarded
func _on_PauseButton_pressed():
	pause()



#warning-ignore:return_value_discarded
func _on_NextButton_pressed():
	play_next_song()

