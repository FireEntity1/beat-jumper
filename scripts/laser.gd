extends Node2D

var is_fired = false
var finished = false

func _ready() -> void:
	$sprite.modulate = Color(1,0,1)
	$sprite.modulate.a = 0
	await get_tree().create_timer(0.8).timeout
	is_fired = true
	await get_tree().create_timer(0.2).timeout
	finished = true
	await get_tree().create_timer(0.8).timeout
	queue_free()

func _process(delta: float) -> void:
	if not is_fired and $sprite.modulate.a < 1:
		$sprite.modulate.a += delta*5
	if is_fired and not finished:
		$sprite.modulate += Color(2.2*delta,1.8*delta,2.2*delta)
		$sprite.modulate.a = 20
	if finished:
		$sprite.modulate.a -= delta*100
