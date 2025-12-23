extends Node2D

@export var edges = 12
@export var radius = 300
@export var amount = 24
@export var speed = 0.125
@export var fire_beat = 1
var offset

@export var pos: Vector2
@export var rot: int

var current = 0

var laser = preload("res://components/laser.tscn")

func _ready() -> void:
	global_position = global.apply_grid(pos) + Vector2(-500,350)
	var angle = 360.0/edges
	offset = -90
	for i in range(amount):
		var index = i%edges
		var current_angle_deg = (angle * index) + offset
		var current_angle_rad = deg_to_rad(current_angle_deg)
		var temp = laser.instantiate()
		temp.pos = Vector2.from_angle(current_angle_rad) * radius
		temp.rot = current_angle_deg + 90
		temp.is_circle = true
		temp.fire_beat = fire_beat + (speed * (current - 1))
		add_child(temp)
		current += 1
		await get_tree().create_timer(speed*(60.0/global.bpm)).timeout

func _process(delta: float) -> void:
	pass
