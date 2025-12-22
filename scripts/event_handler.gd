extends Node2D

var event_types = {
	"laser": preload("res://components/laser.tscn")
	}
@export var bpm = 220
var beat = 0.0
var last_beat = 0.0

var event_index = 0

var prefire_sec = {
	"laser": 0.8
}

var prefire_beat = {
	"laser": prefire_sec.laser * (bpm / 60.0)
}

var events = [
	{
		"type": "laser",
		"beat": 6,
		"pos": Vector2(3,5),
		"rot": 0
	},
	{
		"type": "laser",
		"beat": 6.25,
		"pos": Vector2(3,4),
		"rot": 0
	},
	{
		"type": "laser",
		"beat": 6.5,
		"pos": Vector2(3,3),
		"rot": 0
	},
	{
		"type": "laser",
		"beat": 6.75,
		"pos": Vector2(3,2),
		"rot": 0
	},
	{
		"type": "laser",
		"beat": 7,
		"pos": Vector2(3,1),
		"rot": 0
	},
	{
		"type": "laser",
		"beat": 8,
		"pos": Vector2(1,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 8.25,
		"pos": Vector2(2,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 8.5,
		"pos": Vector2(3,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 8.75,
		"pos": Vector2(4,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 9,
		"pos": Vector2(5,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 9.25,
		"pos": Vector2(6,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 9.5,
		"pos": Vector2(7,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 9.75,
		"pos": Vector2(8,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 10,
		"pos": Vector2(9,3),
		"rot": 90
	},
	{
		"type": "laser",
		"beat": 10.25,
		"pos": Vector2(10,3),
		"rot": 90
	},
]

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	last_beat = beat
	global.last_beat = beat
	beat += (bpm/60)*delta
	global.beat = beat
	while event_index < events.size():
		var event = events[event_index]
		var trigger_beat = event["beat"] - prefire_beat[event["type"]]
		if crossed(last_beat,beat,trigger_beat):
			var temp = event_types[event.type].instantiate()
			temp.fire_beat = event.beat
			temp.pos = event.pos
			temp.rot = event.rot
			add_child(temp)
			event_index += 1
		else:
			break
		
func crossed(prev: float, now: float, target: float):
	return prev < target and now >= target

func sortbeat(a,b):
	return a["beat"] < b["beat"]
