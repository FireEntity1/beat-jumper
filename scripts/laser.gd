extends Node2D

@export var fire_pos: String
@export var fire_beat: float
@export var rot: float
@export var pos: Vector2

var is_fired = false
var finished = false

func _ready() -> void:
	$sprite.modulate = Color(1,0,1)
	$sprite.modulate.a = 0
	position = global.apply_grid(pos)
	rotation_degrees = rot

func _process(delta: float) -> void:
	if not is_fired and $sprite.modulate.a < 1:
		$sprite.modulate.a += delta*2
	
	if not is_fired and crossed(global.last_beat, global.beat, fire_beat):
		start_fire_seq()
	
	if is_fired and not finished:
		$sprite.modulate += Color(8*delta,6.8*delta,7.2*delta)
		$sprite.modulate.a = 20
	
	if finished:
		$sprite.modulate -= Color(10*delta, 10*delta, 10*delta, delta*70)
		if $sprite.modulate.a <= 0:
			queue_free()

func start_fire_seq():
	is_fired = true
	await get_tree().create_timer(0.2).timeout
	finished = true
	
func crossed(prev: float, now: float, target: float) -> bool:
	return prev < target and now >= target
