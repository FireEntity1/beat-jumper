extends Node2D

@export var edges: int
@export var radius: int
@export var amount: int
@export var speed: float
@export var fire_beat = 1.0
@export var distance: int
var offset

@export var colour = ["hotpink", "red"]

var max_cols = 1
var cur_col = 0
var lasers_spawned = 0

@export var pos: Vector2
@export var rot: int
@export var outwards = false

var start_beat: float

var current = 0

var laser = preload("res://components/laser.tscn")

func _ready() -> void:
	start_beat = fire_beat
	global_position = global.apply_grid(pos) + Vector2(280,350)
	max_cols = colour.size()-1

func _process(delta: float) -> void:
	var current_beat = global.beat
	while lasers_spawned < amount:
		var spawn_beat = start_beat + (lasers_spawned * speed) - global.prefire_beat.laser
		if crossed(global.last_beat,global.beat,spawn_beat):
			spawn_laser(lasers_spawned)
			lasers_spawned += 1
		else:
			break

func spawn_laser(pos):
	var temp = laser.instantiate()
	temp.rot = rot
	temp.pos = position + Vector2(distance*current,0)
	temp.snap = false
	temp.fire_beat = fire_beat + (speed * (current - 1))
	temp.colour = colour[cur_col]
	add_child(temp)
	if outwards:
		temp = laser.instantiate()
		temp.rot = rot
		temp.pos = position - Vector2(distance*current,0)
		temp.snap = false
		temp.fire_beat = fire_beat + (speed * (current - 1))
		temp.colour = colour[cur_col]
		add_child(temp)
	if cur_col == max_cols:
		cur_col = 0
	else:
		cur_col += 1
	current += 1

func crossed(prev: float, now: float, target: float):
	return prev <= target and now >= target
