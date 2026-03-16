extends Node2D

const TRACK = preload("res://components/track.tscn")
const EVENT = preload("res://components/editor_event.tscn")

var event_width = 300

signal deselect

var last_beat = {}

var editor_scale = 1.0

@onready var preview = $layer/preview_container/preview/main_game

var lines_layer

var map: Dictionary
var selection = []
var clipboard = []

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
	preview.is_preview = true
	cur_bpm = map.bpm
	$timeline.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$hor_scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	
	lines_layer = Control.new()
	lines_layer.name = "lines_layer"
	lines_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$scroll/tracks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	var i = 0
	for event in global.defaults:
		var track = TRACK.instantiate()
		var name: String = global.defaults[event].type
		track.name = name
		track.gui_input.connect(_on_tracks_gui_input.bind(name))
		last_beat[name] = 0.0
		name = name.replace("_"," ")
		track.change_name(name)
		track.custom_minimum_size.x = time_to_beat($song.stream.get_length()) * event_width
		track.size_flags_horizontal = Control.SIZE_EXPAND
		$scroll/tracks.add_child(track)
		var textbox = Label.new()
		textbox.text = name
		textbox.global_position = Vector2(1500,i*150 + 250)
		textbox.z_index = 1
		textbox.add_theme_color_override("font_color",Color(0.3,0.3,0.3))
		textbox.add_theme_font_size_override("font_size",50)
		$label_layer.add_child(textbox)
		i += 1
		
	spawn_events()
	$hor_scroll.max_value = time_to_beat($song.stream.get_length()) * event_width
	$hor_scroll.value_changed.connect(func(val): 
		$scroll.scroll_horizontal = int(val)
		cursor = val/event_width
	)
	$scroll/tracks.add_child(lines_layer)
	lines_layer.z_index = 100
	lines_layer = $scroll/tracks/lines_layer
	add_lines(1.0,(time_to_beat($song.stream.get_length())), lines_layer)
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("save"):
		save()
	if Input.is_action_just_pressed("play"):
		_on_play_button_up()
	var i = 0
	for child in $label_layer.get_children():
		if child is Label:
			child.position.y = $scroll/tracks.position.y + i*154 + 50
			i += 1
	
	if $song.playing:
		var next_beat = time_to_beat($song.get_playback_position())
		cursor = time_to_beat($song.get_playback_position())
		preview.last_beat = preview.beat
		preview.beat = next_beat
		#$hor_scroll.value = cursor * event_width
		$hor_scroll.set_value_no_signal(cursor*event_width)
		$scroll.scroll_horizontal = int($hor_scroll.value)
		$layer.show()
	else:
		$layer.hide()
	
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
	if Input.is_action_just_pressed("ui_left") and Input.is_action_pressed("shift"):
		move(false)
	elif Input.is_action_just_pressed("ui_right") and Input.is_action_pressed("shift"):
		move(false)
	elif Input.is_action_just_pressed("ui_left"):
		cursor -= editor_scale
		$hor_scroll.value = cursor*event_width
	elif Input.is_action_just_pressed("ui_right"):
		cursor += editor_scale
		$hor_scroll.value = cursor*event_width
	if Input.is_action_just_pressed("ui_down"):
		$scroll.get_v_scroll_bar().value += 154
	if Input.is_action_just_pressed("ui_up"):
		$scroll.get_v_scroll_bar().value -= 154
	
	if Input.is_action_just_pressed("copy"):
		clipboard = selection.duplicate(true)
	if Input.is_action_just_pressed("paste"):
		var events = clipboard.duplicate(true)
		var highest
		var lowest
		if events.size() > 0:
			lowest = events[0]["beat"]
			highest = events[0]["beat"]
		else:
			return
		for event in events:
			if event.beat < lowest:
				lowest = event.beat
			if event.beat > highest:
				highest = event.beat
		for event in events:
			var new_event = event.duplicate(true)
			new_event.beat -= lowest
			new_event.beat += cursor
			new_event.beat = snap(new_event.beat)
			map.data.append(new_event)
		deselect.emit()
		cursor += highest - lowest + editor_scale
		$hor_scroll.value = cursor*event_width
		emit_signal("deselect")
		selection.clear()
		spawn_events()
func spawn_events():
	for child in get_children():
		if child is PopupPanel:
			child.queue_free()
	$selected.text = "SELECTED: " + str(selection.size())
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
		
		var max_width = event_width*float(editor_scale)
		for temp_event in events:
			if temp_event.has("length"):
				var width = temp_event.length * event_width
				max_width = width
		
		var main_event = EVENT.instantiate()
		main_event.load_default(event.type, 0)
		main_event.event_data = event
		main_event.custom_minimum_size.x = max_width
		main_event.parent = self
		
		main_event.position.x = event.beat*event_width
		
		if selection.has(event):
			main_event.selected = true
			main_event.update_selection_visual()
		
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
				popup.size = Vector2(event_width, events.size() * 48)
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
		deselect.connect(main_event._deselect)
		track.add_child(main_event)

func group_events(events):
	var groups = {}
	for event in events:
		var key = str(event.type, "@", float(event.beat))
		if not groups.has(key):
			groups[key] = []
		groups[key].append(event)
	return groups

func add_lines(view_scale: float,beats, parent):
	for beat in int(beats * (1/view_scale)):
		var line = ColorRect.new()
		line.size = Vector2(3,5000)
		line.color = Color(1,1,1,0.1)
		line.position = Vector2(event_width*editor_scale*beat +330,0)
		
		#line.position = Vector2(event_width * beat, 0)
		
		#line.position = Vector2(event_width * view_scale * beat, 0)
		#if line.position.x < event_width*editor_scale:
			#continue
		line.z_index = 100
		line.mouse_filter = Control.MOUSE_FILTER_IGNORE
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
		for child in $scroll/tracks.get_children():
			if child is ColorRect:
				child.update_length(editor_scale,event_width)
		spawn_events()

func _on_tracks_gui_input(event: InputEvent, type: String)-> void:
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_action_pressed("shift"):
		var clicked_beat = (event.position.x - event_width) / event_width
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
			break
	for i in range(selection.size()):
		if selection[i] == event:
			selection.remove_at(i)
			break
	spawn_events()

func move(dir: bool):
	if selection.size() > 0:
		for i in range(selection.size()):
			for event in selection:
				if map.data[i] == event:
					event.beat += (int(dir)*2-1) * editor_scale

func _on_pickfolder_button_up() -> void:
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dialog.use_native_dialog = true
	dialog.connect("dir_selected",load_map)
	add_child(dialog)
	dialog.popup()
	$pickfolder.release_focus()

func load_map(dir: String,load: Array = [true,true,true]):
	save_dir = dir
	if FileAccess.file_exists(dir + "/map.jump") and load[0]:
		var map_string = FileAccess.get_file_as_string(dir + "/map.jump")
		map = JSON.parse_string(map_string)
		map.data = sanitize_json(map.data,true)
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
	var sanitized = sanitize_json(map.data,false)
	var to_save = map.duplicate(true)
	to_save.data = sanitized
	var file = FileAccess.open(save_dir+"/map.jump",FileAccess.WRITE)
	file.store_string(JSON.stringify(to_save))
	file.close()

func update_info():
	$song_length.text = "LENGTH: " + str(int(floor($song.stream.get_length()/60))) + ":" + str(int($song.stream.get_length())%60)
	$song_events.text = "EVENTS: " + str(map.data.size())
	$title.text = map.name
	$subtitle.text = map.sub
	$artist.text = map.artist
	$bpm.text = str(map.bpm)
	$offset.text = str(map.offset)

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
	$play.release_focus()
	if not $song.playing:
		$song.play(beat_to_time(cursor))
		preview.modify(true,beat_to_time(cursor),cursor,map,cur_bpm)
	elif $song.playing:
		$song.stop()
		cursor = snap(cursor)
		preview.modify(false,beat_to_time(cursor),cursor,map)
		$hor_scroll.value = cursor*event_width

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
	var sanitized = array.duplicate(true)
	for event in sanitized:
		if event.has("pos"):
			if to_vector and event.pos is Array:
				event.pos = Vector2(event.pos[0],event.pos[1])
			elif not to_vector and event.pos is Vector2:
				event.pos = [event.pos.x,event.pos.y]
	return sanitized

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
	return time + map.offset

func time_to_beat(time: float):
	time -= map.offset
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

func _on_scroll_scroll_ended() -> void:
	print("scroll ended")

func _on_offset_text_changed(new_text: String) -> void:
	map.offset = max(new_text, 0)
	$offset.text = str(map.offset)

func select(event_data: Dictionary, selected: bool):
	if not selected:
		selection.erase(event_data)
	else:
		selection.append(event_data)
	if selection.size() >= 1:
		$selected.show()
	else:
		$selected.hide()
	$selected.text = "SELECTED: " + str(selection.size())

func _on_editor_scale_drag_ended(value_changed: bool) -> void:
	event_width = $editor_scale.value
	for child in lines_layer.get_children():
		child.queue_free()
	add_lines(editor_scale, time_to_beat($song.stream.get_length()), lines_layer)
	var total_width = time_to_beat($song.stream.get_length()) * event_width
	for track in $scroll/tracks.get_children():
		if track is Control:
			track.custom_minimum_size.x = total_width
	$hor_scroll.max_value = total_width
	$hor_scroll.value = cursor*event_width
	spawn_events()
	$editor_scale.release_focus()

func _on_back_button_up() -> void:
	if loaded.map:
		var map_string = FileAccess.get_file_as_string(save_dir + "/map.jump")
		var saved_map = JSON.parse_string(map_string)
		saved_map.data = sanitize_json(saved_map.data, true)
		if map != saved_map:
			var popup = AcceptDialog.new()
			popup.title = "Unsaved Changes"
			popup.dialog_text = "You have unsaved changes."
			
			popup.ok_button_text = "Save"
			
			var dont_save = popup.add_button("Don't Save", true, "dont_save")
			var cancel = popup.add_button("Cancel", true, "cancel")
			
			add_child(popup)
			popup.popup_centered()
			
			popup.confirmed.connect(func(): 
				save()
				popup.queue_free()
				get_tree().change_scene_to_file("res://scenes/title.tscn")
		)
		
			popup.custom_action.connect(func(action):
				match action:
					"cancel":
						popup.queue_free()
						return
					"dont_save":
						get_tree().change_scene_to_file("res://scenes/title.tscn")
						return
			)
			return
	get_tree().change_scene_to_file("res://scenes/title.tscn")
