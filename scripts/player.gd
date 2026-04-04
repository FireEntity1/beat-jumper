extends CharacterBody2D


const SPEED = 1300.0
const JUMP_VELOCITY = -1700.0

const BASE_ZOOM = 0.67 # haha six seven

var kick_amount = 0.0
var kick_beat_offset = 0.0
var was_kicking = false

var last_beat = 0.0

var is_preview = false

var can_dash = true

var prev_dir = 1
var dashing = false
var jumps = 1

var iframe = false
var hits = 0

var was_on_ground = true

var cam_tilt = 0.0

#var kick_in = false

var scale_target = Vector2(1,1)

@onready var chromabb = $layer/chromabb.material as ShaderMaterial
@onready var shake = $layer2/shake.material as ShaderMaterial
@onready var vhs = $layer3/vhs.material as ShaderMaterial
@onready var glitch = $layer4/glitch.material as ShaderMaterial

func _ready() -> void:
	if get_parent().is_preview:
		hide()
		is_preview = true

func _process(delta: float) -> void:
	if global.camera_kick and not was_kicking:
		kick_beat_offset = fmod(global.beat, global.camera_kick_speed)
	if global.camera_kick:
		var adjusted_beat = global.beat - kick_beat_offset
		var subdivided_last = floor((last_beat - kick_beat_offset) / global.camera_kick_speed)
		var subdivided_current = floor(adjusted_beat / global.camera_kick_speed)
		if subdivided_current != subdivided_last:
			kick_amount = 1.0
	kick_amount = move_toward(kick_amount, 0.0, delta * 8.0)
	last_beat = global.beat
	was_kicking = global.camera_kick
	if not global.chromabb:
		var k = kick_amount
		chromabb.set_shader_parameter("r_displacement",
			chromabb.get_shader_parameter("r_displacement").move_toward(Vector2(10.0*k,-4.0*k),delta*300))
		chromabb.set_shader_parameter("b_displacement",
			chromabb.get_shader_parameter("b_displacement").move_toward(Vector2(-10.0*k,4.0*k),delta*300))
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
		glitch.set_shader_parameter("shake_power",float(global.glitch_intensity)/100.0)
		glitch.set_shader_parameter("shake_color_rate",float(global.glitch_intensity)/100.0)
	else:
		glitch.set_shader_parameter("running", false)
	if global.vhs:
		vhs.set_shader_parameter("intensity",
		move_toward(vhs.get_shader_parameter("intensity"),global.vhs_intensity,delta*3))
	else:
		vhs.set_shader_parameter("intensity",
		move_toward(vhs.get_shader_parameter("intensity"),0.0,delta*3))
	if not global.camera_kick:
		var target = lerpf($camera.zoom.x, global.cam_zoom * BASE_ZOOM, global.cam_speed * delta)
		$camera.position.y = -200 + ($camera.zoom.x*50)
		$camera.zoom = Vector2(target, target)
	else:
		var target_zoom = global.cam_zoom * BASE_ZOOM + kick_amount * 0.06
		$camera.position.y = -200 + ($camera.zoom.x*50)
		$camera.zoom.x = lerpf($camera.zoom.x, target_zoom, delta * 15)
		$camera.zoom.y = lerpf($camera.zoom.y, target_zoom, delta * 15)
	var direction = Input.get_axis("left", "right")
	cam_tilt = lerpf(cam_tilt, -direction * 4.0, delta * 1.5)
	$camera.rotation_degrees = lerpf($camera.rotation_degrees, global.cam_rot + cam_tilt, float(global.cam_speed) * 10.0 * delta)

func _physics_process(delta: float) -> void:
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
		#was_on_ground = true
	was_on_ground = is_on_floor()
	
	if Input.is_action_just_pressed("slam"):
		velocity.y = 10000
		var height = position.y - 171
		
		$sprite.material.set_shader_parameter("dir", Vector2($sprite.material.get_shader_parameter("dir").x,
			height/100))

		$sprite.material.set_shader_parameter("dir", Vector2($sprite.material.get_shader_parameter("dir").x,
		height/1400.0))
		await get_tree().create_timer(0.002).timeout
		#scale_target = Vector2(0.2,3)
		await get_tree().create_timer(0.08).timeout
		$sprite.material.set_shader_parameter("dir", Vector2($sprite.material.get_shader_parameter("dir").x,
			0.0))
		#scale_target = Vector2(1,1)
	
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
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dashing = true
		can_dash = false
		$sprite.material.set_shader_parameter("dir", Vector2(-1.2*prev_dir,
			$sprite.material.get_shader_parameter("dir").y))
		scale_target = Vector2(2,0.2)
		await get_tree().create_timer(0.05).timeout
		scale_target = Vector2(1,1)
		dashing = false
		$sprite.material.set_shader_parameter("dir", Vector2(0,
			$sprite.material.get_shader_parameter("dir").y))
		await get_tree().create_timer(0.3).timeout
		can_dash = true
		
	if dashing:
		velocity.x = prev_dir * 7000
		velocity.y = 0
	
	scale = scale.move_toward(scale_target,0.09)
	move_and_slide()
	if is_preview:
		position = Vector2(0,150)

func hit():
	if not iframe:
		iframe = true
		hits += 1
		$miss.play(0.1)
		await get_tree().create_timer(0.5).timeout
		iframe = false
		
