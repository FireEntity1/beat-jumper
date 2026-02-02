extends Node2D

const TRACK = preload("res://components/track.tscn")
const EVENT = preload("res://components/editor_event.tscn")

const EVENT_WIDTH = 300

var last_beat = {}

var editor_scale = 1.0

var lines_layer

var map: Dictionary
var selection: Array

var loaded = {
	"map": false,
	"song": false,
	"image": false
}

var save_dir: String

var cursor: float

var cur_bpm: float

func _ready() -> void:
	map = global.default_map.duplicate(true)
	cur_bpm = map.bpm
	$timeline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$hor_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	
	lines_layer = Control.new()
	lines_layer.name = "lines_layer"
	lines_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$scroll/tracks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for event in global.defaults:
		var track = TRACK.instantiate()
		var name: String = global.defaults[event].type
		track.name = name
		track.gui_input.connect(_on_tracks_gui_input.bind(name))
		last_beat[name] = 0.0
		name = name.replace("_"," ")
		track.change_name(name)
		track.custom_minimum_size.x = time_to_beat($song.stream.get_length()) * EVENT_WIDTH
		track.size_flags_horizontal = Control.SIZE_EXPAND
		$scroll/tracks.add_child(track)
	spawn_events()
	$hor_scroll.max_value = time_to_beat($song.stream.get_length()) * EVENT_WIDTH
	$hor_scroll.value_changed.connect(func(val): 
		$scroll.scroll_horizontal = int(val)
	)
	$scroll/tracks.add_child(lines_layer)
	lines_layer.z_index = 100
	lines_layer = $scroll/tracks/lines_layer
	add_lines(1.0,(time_to_beat($song.stream.get_length())), lines_layer)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		save()
	
	if $song.playing:
		cursor = time_to_beat($song.get_playback_position())
		$hor_scroll.value = cursor * EVENT_WIDTH
	
	if not loaded.map:
		$pickmusic.disabled = true
		$pickimage.disabled = true
		$pickfolder.modulate = Color(1,0.6,0.6)
	else:
		$pickmusic.disabled = false
		$pickimage.disabled = false
		$pickfolder.modulate = Color(0.6,1.0,0.6)
	
	if not loaded.song:
		$pickmusic.modulate = Color(1,0.6,0.6)
	else:
		$pickmusic.modulate = Color(0.6,1.0,0.6)
	if not loaded.image:
		$pickimage.modulate = Color(1,0.6,0.6)
	else:
		$pickimage.modulate = Color(0.6,1.0,0.6)
	
	if $pickmusic.button_pressed:
		$pickmusic.modulate.a = 0.4
	elif $pickmusic.disabled:
		$pickmusic.modulate.a = 0.2
	else:
		$pickmusic.modulate.a = 1.0
	if $pickimage.button_pressed:
		$pickimage.modulate.a = 0.4
	elif $pickimage.disabled:
		$pickimage.modulate.a = 0.2
	else:
		$pickimage.modulate.a = 1.0
		
	if $pickfolder.button_pressed:
		$pickfolder.modulate.a = 0.4
	elif $pickfolder.disabled:
		$pickfolder.modulate.a = 0.2
	else:
		$pickfolder.modulate.a = 1.0

func spawn_events():
	for track in $scroll/tracks.get_children():
		if track is Control and track.has_node("hbox"):
			var hbox = track.get_node("hbox")
			for child in hbox.get_children():
				child.queue_free()
	for key in last_beat.keys():
		last_beat[key] = 0.0
	
	#for child in get_children():
		#if child is PopupPanel:
			#child.queue_free()
	
	var groups = group_events(map.data)
	for key in groups:
		var events = groups[key]
		var event = events[-1]
		var track = $scroll/tracks.get_node(event.type + "/hbox")
		
		var max_width = EVENT_WIDTH*float(editor_scale)
		for temp_event in events:
			if temp_event.has("length"):
				var width = temp_event.length * EVENT_WIDTH
				max_width = width
		
		var main_event = EVENT.instantiate()
		main_event.load_default(event.type, 0)
		main_event.event_data = event
		main_event.custom_minimum_size.x = max_width
		main_event.parent = self
		
		main_event.position.x = event.beat*EVENT_WIDTH
		
		if events.size() > 1:
			var popup = PopupPanel.new()
			popup.transparent = false
			var popup_container = VBoxContainer.new()
			popup_container.add_theme_constant_override("separation", 4)
			popup.add_child(popup_container)
			
			for e in events:
				var node = EVENT.instantiate()
				node.load_default(e.type, 0)
				node.event_data = e
				node.parent = self
				popup_container.add_child(node)
			
			add_child(popup)
			
			main_event.mouse_entered.connect(func():
				var global_pos = main_event.global_position
				popup.position = global_pos + Vector2(0, 44)
				popup.size = Vector2(EVENT_WIDTH, events.size() * 48)
				popup.popup()
		)
			
			main_event.mouse_exited.connect(func():
				await get_tree().create_timer(0.1).timeout
				var mouse_pos = get_global_mouse_position()
				var popup_rect = Rect2(popup.position, popup.size)
				if not popup_rect.has_point(mouse_pos):
					popup.hide()
			)
			
			popup.mouse_exited.connect(func():
				popup.hide()
			)
		main_event.beat = float(main_event.beat)
		track.add_child(main_event)

func group_events(events):
	var groups = {}
	for event in events:
		var key = str(event.type, "@", float(event.beat))
		if not groups.has(key):
			groups[key] = []
		groups[key].append(event)
	return groups

func add_lines(scale: float,beats, parent):
	for beat in int(beats):
		var line = ColorRect.new()
		line.size = Vector2(3,5000)
		line.color = Color(1,1,1,0.1)
		line.position = Vector2(EVENT_WIDTH*scale*beat + 30,0)
		if line.position.x < 300:
			continue
		line.z_index = 100
		if beat != 0:
			parent.add_child(line)

func eval_exp(text):
	var exp = Expression.new()
	var regex = RegEx.new()
	regex.compile(r"\b(\d+)\b")
	text = regex.sub(text,"$1.0", true)
	if exp.parse(str(text)) == OK:
		var value = exp.execute()
		return value
	else:
		return null

func _on_scale_text_submitted(new_text: String) -> void:
	if eval_exp(new_text) != null:
		for child in lines_layer.get_children():
			child.queue_free()
		editor_scale = eval_exp(new_text)
		add_lines(editor_scale, time_to_beat($song.stream.get_length()), lines_layer)
		spawn_events()

func _on_tracks_gui_input(event: InputEvent, type: String)-> void:
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_action_pressed("shift"):
		var clicked_beat = (event.position.x - EVENT_WIDTH) / EVENT_WIDTH
		clicked_beat = snap(clicked_beat)
		var data = new_event(type,clicked_beat)
		map.data.append(data)
		map.data.sort_custom(func(a,b):return a.beat < b.beat)
		spawn_events()
func pos_to_beat(pos):
	pass

func snap(value: float):
	return floor((value/editor_scale))*editor_scale

func new_event(type, beat):
	var event = global.defaults[type].duplicate(true)
	event.beat = beat
	return event

func modify(old: Dictionary, new: Dictionary):
	for i in range(map.data.size()):
		if map.data[i] == old:
			map.data[i] = new
			return

func delete(event: Dictionary):
	for i in range(map.data.size()):
		if map.data[i] == event:
			map.data.remove_at(i)
			return

func _on_pickfolder_button_up() -> void:
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.use_native_dialog = true
	dialog.connect("dir_selected",load_map)
	add_child(dialog)
	dialog.popup()
	$pickfolder.release_focus()

func load_map(dir: String,load: Array = [true,true,true]):
	print(dir)
	save_dir = dir
	if FileAccess.file_exists(dir + "/map.jump") and load[0]:
		var map_string = FileAccess.get_file_as_string(dir + "/map.jump")
		map = JSON.parse_string(map_string)
		sanitize_json(map.data,true)
		loaded.map = true
	else:
		FileAccess.open(dir+"/map.jump",FileAccess.WRITE).store_string(JSON.stringify(map))
		loaded.map = true
	if FileAccess.file_exists(dir + "/song.ogg") and load[1]:
		#var song_path = dir.path_join("song.ogg")
		var song_path = dir.path_join("song.ogg")
		var song = AudioStreamOggVorbis.load_from_file(song_path)
		loaded.song = true
		$song.stream = song
	if FileAccess.file_exists(dir + "/cover.png") and load[2]:
		loaded.image = true
	elif FileAccess.file_exists(dir + "/cover.jpg") and load[2]:
		loaded.image = true
	update_info()
	
	spawn_events()

func save():
	if save_dir == "":
		return
	sanitize_json(map.data,false)
	var file = FileAccess.open(save_dir+"/map.jump",FileAccess.WRITE)
	file.store_string(JSON.stringify(map))
	file.close
	sanitize_json(map.data,true)

func update_info():
	$song_length.text = "LENGTH: " + str(int(floor($song.stream.get_length()/60))) + ":" + str(int($song.stream.get_length())%60)
	$song_events.text = "EVENTS: " + str(map.data.size())
	$title.text = map.name
	$subtitle.text = map.sub
	$artist.text = map.artist
	$bpm.text = str(map.bpm)

func _on_pickmusic_button_up() -> void:
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.add_filter("*.ogg ; OGG Files")
	dialog.connect("file_selected",load_music)
	add_child(dialog)
	dialog.popup()
	$pickmusic.release_focus()

func load_music(dir):
	var file = FileAccess.open(dir,FileAccess.READ)
	if file == null:
		return
	var data = file.get_buffer(file.get_length())
	file.close()
	var dest = FileAccess.open(save_dir + "/song.ogg",FileAccess.WRITE)
	if dest == null:
		return
	dest.store_buffer(data)
	dest.close()
	load_map(save_dir)
	return data

func load_image(dir: String):
	var file = FileAccess.open(dir,FileAccess.READ)
	if file == null:
		return
	var data = file.get_buffer(file.get_length())
	var dest = FileAccess.open(save_dir + "/cover." + dir.get_extension(),FileAccess.WRITE)
	dest.store_buffer(data)
	dest.close()

func _on_pickimage_button_up() -> void:
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.use_native_dialog = true
	dialog.filters = ["*.png","*.jpg","*.jpeg"]
	dialog.connect("file_selected",load_image)
	add_child(dialog)
	dialog.popup()
	$pickimage.release_focus()

func _on_play_button_up() -> void:
	if not $song.playing:
		$song.play()
	elif $song.playing:
		$song.stop()
		cursor = snap(cursor)

func _on_title_text_changed(new_text: String) -> void:
	map.name = new_text
func _on_subtitle_text_changed(new_text: String) -> void:
	map.sub = new_text
func _on_artist_text_changed(new_text: String) -> void:
	map.artist = new_text
func _on_bpm_text_changed(new_text: String) -> void:
	if float(new_text) > 0:
		map.bpm = float(new_text)

func sanitize_json(array: Array, to_vector: bool):
	for event in array:
		if event.has("pos"):
			if to_vector and event.pos is Array:
				event.pos = Vector2(event.pos[0],event.pos[1])
			elif not to_vector and event.pos is Vector2:
				event.pos = [event.pos.x,event.pos.y]

func get_bpm_changes():
	var events = []
	for event in map.data:
		if event.type == "bpm_change":
			events.append(event)
	events.sort_custom(func(a,b): return a.beat < b.beat)
	
	if events.is_empty() or events[0].beat > 0:
		events.push_front({
			"type": "bpm_change",
			"beat": 0.0,
			"new_bpm": map.bpm
		})
	return events

func beat_to_time(target: float):
	var bpm_changes = get_bpm_changes()
	var time = 0.0
	for i in range(bpm_changes.size()):
		var cur = bpm_changes[i]
		var next_beat = (
			bpm_changes[i+1].beat
			if i+1 < bpm_changes.size()
			else target
		)
		if target <= cur.beat:
			break
		var segment_beats = min(target, next_beat) - cur.beat
		time += segment_beats * (60.0/ cur.new_bpm)
	return time

func time_to_beat(time: float):
	var bpm_changes = get_bpm_changes()
	var elapsed = 0.0
	for i in range(bpm_changes.size()):
		var cur = bpm_changes[i]
		var next_beat = (
			bpm_changes[i+1].beat
			if i+1 < bpm_changes.size()
			else INF
		)
		var segment_time = (next_beat - cur.beat) * (60.0/cur.new_bpm)
		if elapsed + segment_time >= time:
			return cur.beat + (time - elapsed) * (cur.new_bpm/60.0)
		elapsed += segment_time
	return bpm_changes[-1].beat
