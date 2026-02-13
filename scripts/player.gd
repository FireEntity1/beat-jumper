extends CharacterBody2D


const SPEED = 1300.0
const JUMP_VELOCITY = -1700.0

var is_preview = false

var prev_dir = 1
var dashing = false
var jumps = 1

var was_on_ground = true

var kick_in = false

var scale_target = Vector2(1,1)

@onready var chromabb = $layer/chromabb.material as ShaderMaterial
@onready var shake = $layer2/shake.material as ShaderMaterial
@onready var vhs = $layer3/vhs.material as ShaderMaterial
@onready var glitch = $layer4/glitch.material as ShaderMaterial

func _ready() -> void:
	if get_parent().is_preview:
		hide()
		is_preview = true
	pulse_loop()

func pulse_loop():
	while true:
		await get_tree().create_timer((60.0)*global.camera_kick_speed / global.bpm).timeout
		if global.camera_kick:
			kick_in = !kick_in

func _process(delta: float) -> void:
	if not global.camera_kick and not global.chromabb:
		chromabb.set_shader_parameter("r_displacement",Vector2(0,0))
		chromabb.set_shader_parameter("b_displacement",Vector2(0,0))
	if kick_in and not global.chromabb:
		$camera.zoom.x = lerpf($camera.zoom.x,0.69, delta*5)
		$camera.zoom.y = lerpf($camera.zoom.y,0.69, delta*5)
		chromabb.set_shader_parameter("r_displacement",
		chromabb.get_shader_parameter("r_displacement").move_toward(Vector2(10.0,-4.0),delta*300))
		chromabb.set_shader_parameter("b_displacement",
		chromabb.get_shader_parameter("b_displacement").move_toward(Vector2(-10.0,4.0),delta*300))
	elif not kick_in and not global.chromabb:
		$camera.zoom.x = move_toward($camera.zoom.x,0.67, delta)
		$camera.zoom.y = move_toward($camera.zoom.y,0.67, delta)
		chromabb.set_shader_parameter("r_displacement",
		chromabb.get_shader_parameter("r_displacement").move_toward(Vector2(3.0,0),delta*100))
		chromabb.set_shader_parameter("b_displacement",
		chromabb.get_shader_parameter("b_displacement").move_toward(Vector2(-3.0,0),delta*100))
	if global.chromabb:
		var ci = global.chromabb_intensity
		chromabb.set_shader_parameter("r_displacement",
		chromabb.get_shader_parameter("r_displacement").move_toward(Vector2(ci*3,-ci*1.2),delta*300))
		chromabb.set_shader_parameter("b_displacement",
		chromabb.get_shader_parameter("b_displacement").move_toward(Vector2(-ci*3,ci*1.2),delta*300))
	if global.shake:
		shake.set_shader_parameter("Shakeintensity",global.shake_intensity)
	else:
		shake.set_shader_parameter("Shakeintensity",0.0)
	if global.glitch:
		glitch.set_shader_parameter("running", true)
		glitch.set_shader_parameter("shake_power",float(global.glitch_intensity)/100)
	else:
		glitch.set_shader_parameter("running", false)
	if global.vhs:
		vhs.set_shader_parameter("intensity",
		move_toward(vhs.get_shader_parameter("intensity"),global.vhs_intensity,delta*3))
	else:
		vhs.set_shader_parameter("intensity",
		move_toward(vhs.get_shader_parameter("intensity"),0.0,delta*3))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		scale_target = Vector2(1.8,0.3)
		velocity.y = JUMP_VELOCITY
		await get_tree().create_timer(0.08).timeout
		jumps = 1
		scale_target = Vector2(1,1)
	if Input.is_action_just_pressed("jump") and not is_on_floor() and jumps > 0:
		scale_target = Vector2(1.8,0.3)
		velocity.y = JUMP_VELOCITY
		jumps = 0
		await get_tree().create_timer(0.08).timeout
		scale_target = Vector2(1,1)
	if is_on_floor():
		jumps = 1
		was_on_ground = true
	was_on_ground = is_on_floor()
	
	if Input.is_action_just_pressed("slam"):
		velocity.y = 10000
		scale_target = Vector2(0.2,3)
		await get_tree().create_timer(0.08).timeout
		scale_target = Vector2(1,1)
	
	if Input.is_action_just_released("left") or Input.is_action_just_released("right"):
		scale_target = Vector2(1,1)
	
	var direction := Input.get_axis("left", "right")
	if direction and is_on_floor():
		scale_target = Vector2(1.2,0.8)
	if direction:
		velocity.x = direction * SPEED
		prev_dir = direction
	else:
		velocity.x = direction * SPEED
	
	if Input.is_action_just_pressed("dash"):
		dashing = true
		$sprite.material.set_shader_parameter("dir", Vector2(1,0))
		scale_target = Vector2(2,0.2)
		await get_tree().create_timer(0.05).timeout
		scale_target = Vector2(1,1)
		dashing = false
		$sprite.material.set_shader_parameter("dir", Vector2(0,0))
	if dashing:
		velocity.x = prev_dir * 7000
		velocity.y = 0
	
	scale = scale.move_toward(scale_target,0.09)
	move_and_slide()
	if is_preview:
		position = Vector2(0,0)
