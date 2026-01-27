extends Node2D

const TRACK = preload("res://components/track.tscn")
const EVENT = preload("res://components/editor_event.tscn")

var last_beat = {}

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
		"rot": 0,
		"colour": "orange"
	},
	{
		"type": "laser",
		"beat": 15.4,
		"pos": Vector2(5,4.8),
		"rot": 0,
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
		"colours": ["blue"],
		"speed": 3,
		"amount": 10,
		"length": 4.0,
		"pos": Vector2(5,0),
		"rot": 0
	},
	{
		"type": "laser_spread",
		"beat": 8+4,
		"colours": ["blue"],
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
	$scroll/tracks.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for event in global.defaults:
		var track = TRACK.instantiate()
		var name: String = global.defaults[event].type
		track.name = name
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
	
func _process(delta: float) -> void:
	cursor = $hor_scroll.value / EVENT_WIDTH

func spawn_events():
	var groups = group_events(temp_testing_map)
	for key in groups:
		var events = groups[key]
		var event = events[0]
		var track = $scroll/tracks.get_node(event.type + "/hbox")
		add_spacer(track, event.beat, event)
		
		var max_width = EVENT_WIDTH
		for temp_event in events:
			if temp_event.has("length"):
				var width = temp_event.length * EVENT_WIDTH
				if width > max_width:
					max_width = width
		
		var main_event = EVENT.instantiate()
		main_event.load_default(event.type, 0)
		main_event.event_data = event
		main_event.custom_minimum_size.x = max_width
		
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
		
		track.add_child(main_event)

func add_spacer(track, beat, event):
	var spacer = Control.new()
	spacer.custom_minimum_size.x = (event.beat-last_beat[event.type]) * EVENT_WIDTH
	last_beat[event.type] = event.beat
	track.add_child(spacer)

func group_events(events):
	var groups = {}
	for event in events:
		var key = str(event.type, "@", event.beat)
		if not groups.has(key):
			groups[key] = []
		groups[key].append(event)
	return groups

func onload():
	$song_length.text = "LENGTH: " + str(int(floor($song.stream.get_length()/60))) + ":" + str(int($song.stream.get_length())%60)
	$song_events.text = "EVENTS: " + str(temp_testing_map.size())
