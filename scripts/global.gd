extends Node

var bpm = 120
var beat = 0
var last_beat = 0
var grid_mult = Vector2(275,160)
var grid_offset = Vector2(-1660,-670)

var camera_kick = false
var camera_kick_speed = 1.0

var prefire_sec = {
	"laser": 0.6,
	"laser_circle": 0.6,
	"laser_sweep": 0.6,
	
	"platform_colour": 0.0,
	"sun": 0.0,
	"camera_kick": 0.0
}

var prefire_beat = {
	"laser": prefire_sec.laser * (bpm / 60.0),
	"laser_circle": prefire_sec.laser_circle * (bpm / 60.0),
	"laser_sweep": prefire_sec.laser_sweep * (bpm / 60.0),
	
	"platform_colour": prefire_sec.platform_colour * (bpm / 60.0),
	"sun": prefire_sec.sun * (bpm / 60.0),
	"camera_kick": prefire_sec.camera_kick * (bpm / 60.0)
}

const defaults = {
	"laser": {
		"type": "laser",
		"beat": 0,
		"pos": Vector2(1,1),
		"rot": 0,
		"colour": "pink"
	},
	"laser_circle": {
		"type": "laser_circle",
		"beat": 0,
		"pos": Vector2(1,1),
		"rot": 0,
		"radius": 400,
		"amount": 24,
		"edges": 12,
		"speed": 1.0/8.0,
		"colour": ["pink"],
		"direction": 1
	},
	"laser_sweep": {
		"type": "laser_sweep",
		"beat": 0,
		"pos": Vector2(1,1),
		"rot": 90,
		"amount": 12,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["pink"]
	},
	"platform_colour": {
		"type": "platform_colour",
		"beat": 0,
		"colour": "pink"
	},
	"sun": {
		"type": "sun",
		"beat": 0,
		"length": 1
	}
}

const colours = {
	"hotpink": [9,2,7],
	"pink": [8,4,8],
	"blue": [5,8,8],
	"green": [4,8,6],
	"red": [9,6,6],
	"purple": [6,3,9],
	"orange": [9,7,2],
	"white": [7,7,7],
}

const colours_raw = {
	"hotpink": Color(3,1,2.5),
	"pink": Color(3,2,3),
	"blue": Color(1,3,3),
	"green": Color(2,3,2),
	"red": Color(3,1,1.5),
	"purple": Color(2,1,3),
	"orange": Color(3,2,1),
	"white": Color(3,3,3),
}

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func apply_grid(value: Vector2):
	return (value*grid_mult) + grid_offset
