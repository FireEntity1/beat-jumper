extends Control

var song_data: Dictionary # the whole data json file!!
var song: AudioStreamOggVorbis # song itself
var songLength

var loaded = false

var playing = false
var beat = 0
var totalBeats: int

var edit_dialog = AcceptDialog.new()

var selected: int

const event_types = ["bottomL","middleL","topL","leftL","centerL","rightL","diagL","diagR","crtOn","crtOff","flash"] # list of possible events

func _ready():
	$scroll/vbox/eventlist.connect("item_selected", Callable(self, "_event_selected")) #connect map event list

func _process(delta):
	if loaded:
		$seek/seekBar.value = $songPlayer.get_playback_position()*(song_data.bpm / 60.0)
	if playing:
		$play.text = "PAUSE"
	else:
		$play.text = "PLAY"

func _on_load_button_up():
	$FileDialog.show()

func _on_file_dialog_file_selected(path: String):
	var directory = path.split("song.ogg")
	if (FileAccess.file_exists(directory[0]+"song.json")):
		song_data = JSON.parse_string(FileAccess.get_file_as_string(directory[0] + "song.json"))
		print("file found!")
		loadSong(directory[0]+"song.json")
		loadOgg(path)
	else:
		$notice.dialog_text = "Song not found"
		$notice.popup_centered()

func loadSong(path):
	$bpm.text = str(song_data.bpm)
	$name.text = song_data.name
	$bpmTimer.wait_time = 1/(song_data.bpm/60)/2
	loadEvents()

func loadOgg(path):
	song = AudioStreamOggVorbis.load_from_file(path)
	print(path)
	$songPlayer.stream = song
	songLength = $songPlayer.stream.get_length()
	$seek.max_value = int(songLength * (song_data.bpm / 60.0))
	$seek/seekBar.max_value = int(songLength * (song_data.bpm / 60.0))
	$seek.step = 0.5
	$seek/seekBar.step = 0.5
	$seek.custom_step = 0.5
	loaded = true
	return AudioStreamOggVorbis.load_from_file(path)

func _on_bpm_text_changed(new_text):
	song_data.bpm = float(new_text)

func _on_name_text_changed(new_text):
	song_data.name = new_text

func loadEvents():
	$scroll/vbox/eventlist.clear()
	sort_events_by_beat()
	for event in song_data.events:
		$scroll/vbox/eventlist.add_item(event.type + ", " + str(event.beat))

func _on_eventlist_item_selected(index):
	$scroll/vbox/eventlist.deselect_all()
	var delButton = Button.new()
	edit_dialog = AcceptDialog.new()
	var beat_input = LineEdit.new()
	var type_dropdown = OptionButton.new()
	delButton.connect("button_up",Callable(self,"_delete_selected"))
	delButton.text = "Delete"
	for type in event_types:
		type_dropdown.add_item(type)
	
	selected = index
	
	var current_event = song_data.events[selected]
	beat_input.text = str(current_event.beat)
	type_dropdown.selected = event_types.find(current_event.type)
	
	var vbox = VBoxContainer.new()
	vbox.add_child(beat_input)
	vbox.add_child(type_dropdown)
	vbox.add_child(delButton)
	edit_dialog.add_child(vbox)
	edit_dialog.title = "Edit"
	add_child(edit_dialog)
	
	edit_dialog.connect("confirmed", func(): 
		_update_event(selected, beat_input.text, type_dropdown.selected)
	)
	edit_dialog.popup()
	edit_dialog.position = get_viewport().get_mouse_position()

func _delete_selected():
	song_data.events.remove_at(selected)
	loadEvents()
	edit_dialog.queue_free()

func _update_event(selected,beat_input,type_dropdown):
	song_data.events[selected].beat = float(beat_input)
	song_data.events[selected].type = event_types[type_dropdown]
	loadEvents()

func sort_events_by_beat():
	song_data.events.sort_custom(func(a, b): return a.beat < b.beat)

func _on_play_button_up():
	if not playing:
		$songPlayer.play()
		$scroll/vbox/eventlist.select(0)
		$bpmTimer.start()
		playing = true
	else:
		$songPlayer.stop()

func _on_bpm_timer_timeout():
	beat += 0.5
	var i = 0
	for event in song_data.events:
		if event.beat == beat:
			$scroll/vbox/eventlist.select(i)
			if not event.type == "crtOn" and not event.type == "crtOff":
				$tick.play()
		i += 1

func _on_new_event_button_up():
	var amt = len(song_data.events)
	song_data.events.append({"type":"centerL", "beat":song_data.events[amt-1].beat+0.5})
	loadEvents()

func _on_save_button_up():
	$saveDialog.show()

func _on_save_dialog_dir_selected(dir):
	FileAccess.open(dir+"/song.json", FileAccess.WRITE).store_string(str(song_data))

func _on_seek_value_changed(value):
	$songPlayer.play(value*(1/(song_data.bpm/60)))
	beat = value
	$bpmTimer.stop()
	$bpmTimer.start()
	$seek/seekBar.value = beat
	print(str(beat))

func _on_return_button_up():
	get_tree().change_scene_to_file("res://Scenes/title.tscn")

func _on_new_button_up():
	$newDialog.show()

func _on_new_dialog_file_selected(path):
	var directory = path.split("song.ogg")
	if (FileAccess.file_exists(path)):
		song_data = {
			"name": "New Song",
			"bpm": 120,
			"events": [
				{
					"type": "centerL",
					"beat": 5
				}
			]
		}
		loadSong(song_data)
		loadOgg(path)
	else:
		$notice.dialog_text = "song.ogg not found"
		$notice.popup_centered()
