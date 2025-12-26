extends Node2D

var event_types = {
	"laser": preload("res://components/laser.tscn"),
	"laser_circle": preload("res://components/laser_circle.tscn"),
	"laser_sweep": preload("res://components/laser_sweep.tscn")
	}
@export var bpm = 150
var beat = 0.0
var last_beat = 0.0

var event_index = 0

var prefire_sec = {
	"laser": 0.6,
	"laser_circle": 0.6,
	"laser_sweep": 0.6,
	
	"platform_colour": 0.0
}

var prefire_beat = {
	"laser": prefire_sec.laser * (bpm / 60.0),
	"laser_circle": prefire_sec.laser_circle * (bpm / 60.0),
	"laser_sweep": prefire_sec.laser_sweep * (bpm / 60.0),
	
	"platform_colour": prefire_sec.platform_colour * (bpm / 60.0)
}

var event_classes = {
	"movable": ["laser", "laser_circle", "laser_sweep"],
	"screen_effect": ["shake", "glitch","platform_colour"]
}

var target_platform_colour = global.colours_raw["pink"]
var platform_colour_speed = 1

var events = [
	{
		"type": "platform_colour",
		"beat": 1,
		"colour": "purple",
		"speed": 1
	},
	{
		"type": "laser_sweep",
		"beat": 4,
		"pos": Vector2(5,1),
		"rot": 90,
		"amount": 8,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["purple", "pink"]
	},
		{
		"type": "platform_colour",
		"beat": 5,
		"colour": "blue",
		"speed": 1
	},
	{
		"type": "laser",
		"beat": 5,
		"pos": Vector2(2,5),
		"rot": 0,
		"colour": "purple"
	},
	{
		"type": "platform_colour",
		"beat": 7,
		"colour": "green",
		"speed": 1
	},
	{
		"type": "platform_colour",
		"beat": 9,
		"colour": "hotpink",
		"speed": 2
	},
	{
		"type": "laser_circle",
		"beat": 10,
		"pos": Vector2(5,3),
		"rot": 0,
		"radius": 500,
		"amount": 48,
		"edges": 12,
		"speed": 1.0/16.0,
		"colour": ["hotpink", "red"]
	},
	{
		"type": "platform_colour",
		"beat": 14,
		"colour": "red",
		"speed": 5
	},
	{
		"type": "laser_sweep",
		"beat": 15,
		"pos": Vector2(3,1),
		"rot": 90,
		"amount": 12,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": false,
		"colour": ["red"]
	},
	{
		"type": "laser_circle",
		"beat": 17,
		"pos": Vector2(5,3),
		"rot": 0,
		"radius": 300,
		"amount": 64,
		"edges": 5,
		"speed": 1.0/32.0,
		"colour": ["hotpink", "red"]
	},
]

func _ready() -> void:
	events.sort_custom(sort_by_trigger_beat)
	$main_platform/platform_sprite.modulate = global.colours_raw["purple"]

func _process(delta: float) -> void:
	global.bpm = bpm
	last_beat = beat
	beat += (bpm/60)*delta
	global.beat = beat
	
	$main_platform/platform_sprite.modulate.r = move_toward($main_platform/platform_sprite.modulate.r,target_platform_colour[0],delta*platform_colour_speed)
	$main_platform/platform_sprite.modulate.g = move_toward($main_platform/platform_sprite.modulate.g,target_platform_colour[1],delta*platform_colour_speed)
	$main_platform/platform_sprite.modulate.b = move_toward($main_platform/platform_sprite.modulate.b,target_platform_colour[2],delta*platform_colour_speed)
	
	while event_index < events.size():
		var event = events[event_index]
		var trigger_beat = event["beat"] - prefire_beat[event["type"]]
		if crossed(last_beat,beat,trigger_beat):
			var temp
			if event.type == "platform_colour":
				target_platform_colour = global.colours_raw[event.colour]
				platform_colour_speed = event.speed
				event_index += 1
				continue
			elif event.type in event_types:
				temp = event_types[event.type].instantiate()
				temp.fire_beat = event.beat
				if event.type in event_classes.movable:
					temp.pos = event.pos
					temp.rot = event.rot
				match event.type:
					"laser":
						temp.colour = event.colour
					"laser_circle":
						temp.speed = event.speed
						temp.radius = event.radius
						temp.edges = event.edges
						temp.amount = event.amount
						temp.colour = event.colour
					"laser_sweep":
						temp.speed = event.speed
						temp.amount = event.amount
						temp.distance = event.distance
						temp.outwards = event.outwards
						temp.colour = event.colour
				add_child(temp)
				event_index += 1
			
		else:
			break
	
func crossed(prev: float, now: float, target: float):
	return prev <= target and now >= target

func sortbeat(a,b):
	return a["beat"] < b["beat"]

func sort_by_trigger_beat(a, b):
	var trigger_a = a["beat"] - prefire_beat[a["type"]]
	var trigger_b = b["beat"] - prefire_beat[b["type"]]
	return trigger_a < trigger_b
