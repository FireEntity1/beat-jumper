extends Node2D

@export var edges: int
@export var radius: int
@export var amount: int
@export var speed: float
@export var fire_beat = 1.0
@export var colour = ["hotpink", "blue", "pink"]
var offset

@export var pos: Vector2
@export var rot: int

var current = 0

var laser = preload("res://components/laser.tscn")

func _ready() -> void:
	global_position = global.apply_grid(pos) + Vector2(300,350)
	var max_cols = colour.size()
	var cur_col = 0
	var angle = 360.0/edges
	offset = -90
	for i in range(amount):
		var index = i%edges
		var current_angle_deg = (angle * index) + offset
		var current_angle_rad = deg_to_rad(current_angle_deg)
		var temp = laser.instantiate()
		temp.pos = Vector2.from_angle(current_angle_rad) * radius
		temp.rot = current_angle_deg + 90
		temp.snap = false
		temp.fire_beat = fire_beat + (speed * (current - 1))
		temp.colour = colour[cur_col]
		add_child(temp)
		current += 1
		if cur_col == max_cols-1:
			cur_col = 0
		else:
			cur_col += 1
		await get_tree().create_timer(speed*(60.0/global.bpm)).timeout

func _process(delta: float) -> void:
	pass
