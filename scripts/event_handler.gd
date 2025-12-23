extends Node2D

var event_types = {
	"laser": preload("res://components/laser.tscn"),
	"laser_circle": preload("res://components/laser_circle.tscn")
	}
@export var bpm = 220
var beat = 0.0
var last_beat = 0.0

var event_index = 0

var prefire_sec = {
	"laser": 0.8,
	"laser_circle": 0.8
}

var prefire_beat = {
	"laser": prefire_sec.laser * (bpm / 60.0),
	"laser_circle": prefire_sec.laser_circle * (bpm / 60.0)
}

var events = [
	{
		"type": "laser_circle",
		"beat": 10,
		"pos": Vector2(10,1),
		"rot": 0,
		"radius": 300,
		"amount": 96,
		"edges": 16,
		"speed": 1.0/24.0
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
			temp.pos = event.pos
			temp.rot = event.rot
			match event.type:
				"laser_circle":
					temp.speed = event.speed
					temp.radius = event.radius
					temp.edges = event.edges
					temp.amount = event.amount
			add_child(temp)
			event_index += 1
			
		else:
			break
			
func crossed(prev: float, now: float, target: float):
	return prev < target and now >= target

func sortbeat(a,b):
	return a["beat"] < b["beat"]
