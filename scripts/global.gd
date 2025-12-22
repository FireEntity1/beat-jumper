extends Node

var beat = 0
var last_beat = 0
var grid_mult = Vector2(275,160)
var grid_offset = Vector2(-1660,-670)

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func apply_grid(value: Vector2):
	return (value*grid_mult) + grid_offset
