extends Node2D

var laser = preload("res://components/laser.tscn")
@export var bpm = 120

var beat = 0.0
var last_beat = 0.0

var event = 6

func _ready() -> void:
	await get_tree().create_timer(1).timeout
	add_child(laser.instantiate())

func _process(delta: float) -> void:
	last_beat = beat
	global.last_beat = beat
	beat += (bpm/60)*delta
	global.beat = beat
	if last_beat-2 < event-2 and beat-2 >= event-2:
		var temp = laser.instantiate()
		temp.fire_beat = beat
		add_child(temp)
