extends Node2D

const TRACK = preload("res://components/track.tscn")
const EVENT = preload("res://components/editor_event.tscn")

var last_beat = {}

var editor_scale = 1.0

var lines_layer

var map: Dictionary
var selection: Array

var cursor: float

const EVENT_WIDTH = 300

var bpm = 118
var temp_testing_map = [
	{
		"type": "visualizer",
		"beat": 4,
		"status": false
	},
	{
		"type": "laser_circle",
		"beat": 0+4,
		"pos": Vector2(4,3),
		"rot": 0,
		"radius": 400,
		"amount": 12,
		"edges": 12,
		"speed": 1.0/6.0,
		"colour": ["pink","red"],
		"direction": 1
	},
	{
		"type": "laser_circle",
		"beat": 2+4,
		"pos": Vector2(7,3),
		"rot": 90,
		"radius": 400,
		"amount": 12,
		"edges": 12,
		"speed": 1.0/6.0,
		"colour": ["purple","blue"],
		"direction": -1
	},
	{
		"type": "platform_colour",
		"beat": 4,
		"colour": "black",
		"speed": 10
	},
	{
		"type": "visualizer",
		"beat": 4+4,
		"status": true
	},
	{
		"type": "platform_colour",
		"beat": 4+3,
		"colour": "pink",
		"speed": 5
	},
	{
		"type": "laser",
		"beat": 15,
		"pos": Vector2(5,5.2),
		"rot": 315,
		"colour": "orange"
	},
	{
		"type": "laser",
		"beat": 15.4,
		"pos": Vector2(5,4.8),
		"rot": 45,
		"colour": "purple"
	},
	{
		"type": "platform_colour",
		"beat": 4+4,
		"colour": "pink",
		"speed": 50
	},
	{
		"type": "laser_sweep",
		"beat": 11,
		"pos": Vector2(5,1),
		"rot": 90,
		"amount": 16,
		"speed": 1.0/16.0,
		"distance": 300,
		"outwards": true,
		"colour": ["pink"]
	},
	{
		"type": "laser_slam",
		"beat": 8,
		"pos": Vector2(3,1),
		"rot": 0,
		"colour": "pink",
		"length": 3.0
	},
	{
		"type": "laser_slam",
		"beat": 8,
		"pos": Vector2(9,1),
		"rot": 0,
		"colour": "pink",
		"length": 3.0
	},
	{
		"type": "glitch",
		"beat": 4+4,
		"length": 3,
		"strength": 0.5
	},
	{
		"type": "platform_colour",
		"beat": 7+4,
		"colour": "black",
		"speed": 10
	},
	{
		"type": "platform_colour",
		"beat": 8+4,
		"colour": "blue",
		"speed": 50
	},
	{
		"type": "laser_spread",
		"beat": 8+4,
		"colour": ["blue"],
		"speed": 3,
		"amount": 10,
		"length": 4.0,
		"pos": Vector2(5,0),
		"rot": 0
	},
	{
		"type": "laser_spread",
		"beat": 8+4,
		"colour": ["blue"],
		"speed": 3,
		"amount": 10,
		"length": 4.0,
		"pos": Vector2(7,3),
		"rot": 0
	},
	{
		"type": "glitch",
		"beat": 8+4,
		"length": 4,
		"strength": 0.5
	},
	{
		"type": "platform_colour",
		"beat": 12+4,
		"colour": "black",
		"speed": 5
	},
	{
		"type": "visualizer",
		"beat": 12+4,
		"status": false
	},
	
]

func _ready() -> void:
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
		track.custom_minimum_size.x = ($song.stream.get_length()*bpm/60) * EVENT_WIDTH
		track.size_flags_horizontal = Control.SIZE_EXPAND
		$scroll/tracks.add_child(track)
	spawn_events()
	$hor_scroll.max_value = ($song.stream.get_length()*bpm/60) * EVENT_WIDTH
	$hor_scroll.value_changed.connect(func(val): 
		$scroll.scroll_horizontal = int(val)
	)
	onload()
	$scroll/tracks.add_child(lines_layer)
	lines_layer.z_index = 100
	lines_layer = $scroll/tracks/lines_layer
	add_lines(1.0,($song.stream.get_length() * bpm) / 60.0, lines_layer)
	
func _process(delta: float) -> void:
	cursor = $hor_scroll.value / EVENT_WIDTH

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
	
	var groups = group_events(temp_testing_map)
	for key in groups:
		var events = groups[key]
		var event = events[-1]
		var track = $scroll/tracks.get_node(event.type + "/hbox")
		#add_spacer(track, event.beat, event)
		
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

func add_spacer(track, beat, event):
	var spacer = Control.new()
	spacer.custom_minimum_size.x = (event.beat-last_beat[event.type]) * EVENT_WIDTH
	last_beat[event.type] = event.beat
	track.add_child(spacer)

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

func onload():
	$song_length.text = "LENGTH: " + str(int(floor($song.stream.get_length()/60))) + ":" + str(int($song.stream.get_length())%60)
	$song_events.text = "EVENTS: " + str(temp_testing_map.size())

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
		add_lines(editor_scale,($song.stream.get_length() * bpm) / 60.0,lines_layer)
		spawn_events()

func _on_tracks_gui_input(event: InputEvent, type: String)-> void:
	if event is InputEventMouseButton and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and Input.is_action_pressed("shift"):
		var clicked_beat = (event.position.x - EVENT_WIDTH) / EVENT_WIDTH
		clicked_beat = snap(clicked_beat)
		var data = new_event(type,clicked_beat)
		temp_testing_map.append(data)
		temp_testing_map.sort_custom(func(a,b):return a.beat < b.beat)
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
	for i in range(temp_testing_map.size()):
		if temp_testing_map[i] == old:
			temp_testing_map[i] = new
			print("changed!")
			return

func delete(event: Dictionary):
	for i in range(temp_testing_map.size()):
		if temp_testing_map[i] == event:
			temp_testing_map.remove_at(i)
			return
