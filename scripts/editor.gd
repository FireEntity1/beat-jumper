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
func _process(delta: float) -> void:
	cursor = $hor_scroll.value / EVENT_WIDTH

func spawn_events():
	for event in temp_testing_map:
		var track = $scroll/tracks.get_node(event.type + "/hbox")
		var event_node = EVENT.instantiate()
		add_spacer(track,event.beat, event)
		event_node.load_default(event.type,0)
		event_node.event_data = event
		track.add_child(event_node)

func add_spacer(track, beat, event):
	var spacer = Control.new()
	spacer.custom_minimum_size.x = (event.beat-last_beat[event.type]) * EVENT_WIDTH
	last_beat[event.type] = event.beat
	track.add_child(spacer)
