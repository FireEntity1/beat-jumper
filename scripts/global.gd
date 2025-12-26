extends Node

var bpm = 120
var beat = 0
var last_beat = 0
var grid_mult = Vector2(275,160)
var grid_offset = Vector2(-1660,-670)

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
		"colour": ["pink"]
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
