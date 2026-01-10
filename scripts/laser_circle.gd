extends Node2D

@export var edges: int
@export var radius: int
@export var amount: int
@export var speed: float
@export var fire_beat = 1.0
@export var colour = ["hotpink", "blue", "pink"]
@export var direction = 1
var offset
var start_beat: float

@export var pos: Vector2
@export var rot: int

var current = 0

var laser = preload("res://components/laser.tscn")

var max_cols: int
var cur_col: int
var angle: float

var lasers_spawned = 0

func _ready() -> void:
	global_position = global.apply_grid(pos) + Vector2(300,350)
	max_cols = colour.size()
	cur_col = 0
	angle = 360.0/edges
	offset = -90
	start_beat = fire_beat

func _process(delta: float) -> void:
	var current_beat = global.beat
	while lasers_spawned < amount:
		var spawn_beat = start_beat + (lasers_spawned * speed) - global.prefire_beat.laser
		if crossed(global.last_beat,global.beat,spawn_beat):
			spawn_laser(lasers_spawned)
			lasers_spawned += 1
		else:
			break

func spawn_laser(index: int):
	var edge_index = index % edges
	var current_angle_deg = ((angle * edge_index) + offset) * direction
	var current_angle_rad = deg_to_rad(current_angle_deg)
	
	var temp = laser.instantiate()
	temp.pos = Vector2.from_angle(current_angle_rad) * radius
	temp.rot = current_angle_deg + 90
	temp.snap = false
	temp.fire_beat = start_beat + index * speed
	temp.colour = colour[cur_col]
	add_child(temp)
	
	cur_col = (cur_col + 1) % max_cols

func crossed(prev: float, now: float, target: float):
	return prev <= target and now >= target
