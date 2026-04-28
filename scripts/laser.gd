extends Area2D

@onready var parent = get_parent() if get_parent().name=="main_game" else get_parent().get_parent()

@export var is_slam = false

@export var fire_pos: String
@export var fire_beat: float
@export var rot: float
@export var pos: Vector2
@export var snap = true
@export var colour = "pink"
var is_fired = false
var finished = false

@onready var smear = $smear

var velocity = Vector2(0,0)
var moving = false
var move = {
	"enabled": false,
	"speed": 1.0,
	"ease": 1.0,
	"always": false,
	"dir_x": 0.0,
	"dir_y": 0.0,
	"focus": false,
}

@export var fire_hold = 0.0
@export var edge = false

func _ready() -> void:
	parent = get_parent() if get_parent().name=="main_game" else get_parent().get_parent()
	moving = move.always
	#print("Began prefire: ", global.beat, " for fire beat: ", fire_beat)
	body_entered.connect(_on_body_entered)
	rotation_degrees = rot
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
	if smear:
		smear.modulate = $sprite.modulate/2
		smear.modulate.a = 0

func _process(delta: float) -> void:
	if moving and not move.focus:
		velocity.x = move.dir_x*move.speed
		velocity.y = move.dir_y*move.speed
		if smear:
			#print("smearing!")
			smear.modulate.a = lerpf(smear.modulate.a,1.0,min(delta*1000.0,1.0))
			smear.scale.x = lerpf(smear.scale.x, move.speed/1000,min(delta*5.0,1.0))
		if smear and finished:
			smear.modulate.a = lerpf(smear.modulate.a, 0.0,min(delta*1000.0,1.0))
			smear.scale.x = lerpf(smear.scale.x,0.0,min(delta*5.0,1.0))
	elif not moving and move.enabled:
		smear.modulate.a = lerpf(smear.modulate.a,0.3,min(delta*10.0,1.0))
		smear.scale.x = lerpf(smear.scale.x, -move.speed/1000,min(delta*2.0,1.0))
	elif move.focus:
		global_position = parent.get_node("player").global_position
		
	position += velocity*delta
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
	
	if fire_hold >= 0.1 and global.beat >= (fire_beat+fire_hold) and not finished:
		finish_laser()
	
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
	if parent.is_preview == true:
		parent.click()
	if is_fired:
		return
	is_fired = true
	
	if is_slam:
		$particles.emitting = true
		$sprite.scale.x = 7
	#print("Fired: ", fire_beat, " at ", global.beat)
	if move.enabled:
		moving = true
	var hold_time = 0.1
	if fire_hold >= 0.1:
		hold_time = (60/global.bpm)*fire_hold
	for body in get_overlapping_bodies():
		if body is CharacterBody2D:
			body.hit()
	await get_tree().create_timer(hold_time).timeout
	finish_laser()
	await get_tree().create_timer(3.0).timeout
	queue_free()
	
func crossed(prev: float, now: float, target: float) -> bool:
	return prev < target and now >= target

func _on_body_entered(body):
	if is_fired and not finished and body is CharacterBody2D:
		body.hit()

func finish_laser():
	monitoring = false
	await get_tree().create_timer(0.1).timeout
	finished = true
