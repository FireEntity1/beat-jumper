extends Node2D

var event_types = {
	"laser": preload("res://components/laser.tscn"),
	"laser_circle": preload("res://components/laser_circle.tscn"),
	"laser_sweep": preload("res://components/laser_sweep.tscn")
	}
@export var bpm = 220
var beat = 0.0
var last_beat = 0.0

var event_index = 0

var prefire_sec = {
	"laser": 0.8,
	"laser_circle": 0.8,
	"laser_sweep": 0.8
	
}

var prefire_beat = {
	"laser": prefire_sec.laser * (bpm / 60.0),
	"laser_circle": prefire_sec.laser_circle * (bpm / 60.0),
	"laser_sweep": prefire_sec.laser_circle * (bpm / 60.0)
}

var event_classes = {
	"movable": ["laser", "laser_circle", "laser_sweep"],
	"screen_effect": ["shake", "glitch"]
}


var events = [
	{
		"type": "laser",
		"beat": 5,
		"pos": Vector2(5,3),
		"rot": 45
	},
	{
		"type": "laser_circle",
		"beat": 10,
		"pos": Vector2(5,3),
		"rot": 0,
		"radius": 670,
		"amount": 10,
		"edges": 10,
		"speed": 1.0/8.0,
	},
	{
		"type": "laser_sweep",
		"beat": 15,
		"pos": Vector2(1,1),
		"rot": 90,
		"amount": 90,
		"speed": 1.0/8.0,
		"distance": 100
	}
]

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	global.bpm = bpm
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
			if event.type in event_classes.movable:
				temp.pos = event.pos
				temp.rot = event.rot
			elif event.type in event_classes.screen_effect:
				temp.time = event.time
			match event.type:
				"laser_circle":
					temp.speed = event.speed
					temp.radius = event.radius
					temp.edges = event.edges
					temp.amount = event.amount
				"laser_sweep":
					temp.speed = event.speed
					temp.amount = event.amount
					temp.distance = event.distance
			add_child(temp)
			event_index += 1
			
		else:
			break
			
func crossed(prev: float, now: float, target: float):
	return prev < target and now >= target

func sortbeat(a,b):
	return a["beat"] < b["beat"]
