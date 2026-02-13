extends Area2D

@export var is_slam = false

@export var fire_pos: String
@export var fire_beat: float
@export var rot: float
@export var pos: Vector2
@export var snap = true
@export var colour = "pink"
var is_fired = false
var finished = false

@export var fire_hold = 0.0
@export var edge = false

func _ready() -> void:
	print("Began prefire: ", global.beat, " for fire beat: ", fire_beat)
	if edge:
		$sprite.position = Vector2(-7147,-4)
	$sprite.modulate.r = global.colours[colour][0]/8
	$sprite.modulate.g = global.colours[colour][1]/8
	$sprite.modulate.b = global.colours[colour][2]/8
	if snap:
		position = global.apply_grid(pos)
	else:
		position = pos
	if is_slam:
		position.y = 242
	await get_tree().create_timer(2).timeout

func _process(delta: float) -> void:
	rotation_degrees = rot
	if not is_fired and $sprite.modulate.a < 1:
		$sprite.modulate.a += delta*2
	
	if not is_fired and crossed(global.last_beat, global.beat, fire_beat):
		start_fire_seq()
	
	if is_fired and not finished:
		$sprite.modulate += Color(global.colours[colour][0]*delta,global.colours[colour][1]*delta,global.colours[colour][2]*delta)
		$sprite.modulate.r = clamp($sprite.modulate.r,0,global.colours[colour][0]/3)
		$sprite.modulate.g = clamp($sprite.modulate.g,0,global.colours[colour][1]/3)
		$sprite.modulate.b = clamp($sprite.modulate.b,0,global.colours[colour][2]/3)
		$sprite.modulate.a = 4
	
	if finished:
		$sprite.modulate -= Color(10*delta, 10*delta, 10*delta, delta*70)
		if $sprite.modulate.a <= 0:
			queue_free()

func start_fire_seq():
	var parent: Node2D
	if get_parent().get_parent().get_parent().has_method("click"):
		parent = get_parent().get_parent().get_parent()
	else:
		parent = get_parent().get_parent()
	parent.click()
	if is_fired:
		return
	is_fired = true
	if is_slam:
		$particles.emitting = true
		$sprite.scale.x = 7
	print("Fired: ", fire_beat, " at ", global.beat)
	var hold_time = 0.2
	if fire_hold >= 0.1:
		hold_time = (60/global.bpm)*fire_hold
	await get_tree().create_timer(hold_time).timeout
	finished = true
	await get_tree().create_timer(10.0).timeout
	queue_free()
	
func crossed(prev: float, now: float, target: float) -> bool:
	return prev < target and now >= target
