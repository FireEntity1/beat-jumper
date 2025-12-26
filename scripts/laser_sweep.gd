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

@export var pos: Vector2
@export var rot: int
@export var outwards = false

var current = 0

var laser = preload("res://components/laser.tscn")

func _ready() -> void:
	global_position = global.apply_grid(pos) + Vector2(280,350)
	var max_cols = colour.size()-1
	for i in range(amount):
		var temp = laser.instantiate()
		temp.rot = rot
		temp.pos = position + Vector2(distance*i,0)
		temp.snap = false
		temp.fire_beat = fire_beat + (speed * (current - 1))
		temp.colour = colour[cur_col]
		add_child(temp)
		if outwards:
			temp = laser.instantiate()
			temp.rot = rot
			temp.pos = position - Vector2(distance*i,0)
			temp.snap = false
			temp.fire_beat = fire_beat + (speed * (current - 1))
			temp.colour = colour[cur_col]
			add_child(temp)
		if cur_col == max_cols:
			cur_col = 0
		else:
			cur_col += 1
		current += 1
		await get_tree().create_timer(speed*(60.0/global.bpm)).timeout

func _process(delta: float) -> void:
	pass
