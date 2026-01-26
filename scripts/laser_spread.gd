extends Node2D

const LASER = preload("res://components/laser.tscn")

@export var colours = ["pink"]

@export var amount = 1
@export var speed = 10

var cur_speed = 0

@export var pos = Vector2(5,5)
@export var rot = 0

@export var length = 1.0

@export var fire_beat = 0.0

var lasers = []

func _ready() -> void:
	position = Vector2(global.apply_grid(pos).x, 120)
	for i in range(amount):
		var temp = LASER.instantiate()
		temp.rot = 90
		temp.fire_beat = fire_beat + 0.05*i
		temp.pos = global_position
		temp.colour = colours[i%colours.size()]
		temp.snap = false
		temp.fire_hold = length
		temp.edge = true
		lasers.append(temp)
		add_child(temp)
		await get_tree().create_timer(0.1)

func _process(delta: float) -> void:
	var i = 1
	if global.beat > fire_beat + 10:
		queue_free()
	# go slow b4 fire (looks cool)
	if global.beat < fire_beat:
		cur_speed = move_toward(cur_speed,speed/4,delta*10)
		for laser in lasers:
			if i % 2 == 0:
				laser.rot += delta*cur_speed*i
			else:
				laser.rot -= delta*cur_speed*i
			i += 1
	# zoom zoom after fire 
	elif global.beat < fire_beat + length:
		cur_speed = move_toward(cur_speed,speed,delta*10)
		for laser in lasers:
			if i % 2 == 0:
				laser.rot += delta*cur_speed*i
			else:
				laser.rot -= delta*cur_speed*i
			i += 1
