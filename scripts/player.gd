extends CharacterBody2D


const SPEED = 1300.0
const JUMP_VELOCITY = -1700.0

var prev_dir = 1
var dashing = false
var jumps = 1

var scale_target = Vector2(1,1)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		scale_target = Vector2(1.8,0.3)
		velocity.y = JUMP_VELOCITY
		jumps = 1
		await get_tree().create_timer(0.08).timeout
		scale_target = Vector2(1,1)
	if Input.is_action_just_pressed("jump") and not is_on_floor() and jumps > 0:
		scale_target = Vector2(1.8,0.3)
		velocity.y = JUMP_VELOCITY
		jumps = 0
		await get_tree().create_timer(0.08).timeout
		scale_target = Vector2(1,1)
	if is_on_floor():
		jumps = 1
	
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
		scale_target = Vector2(2,0.2)
		await get_tree().create_timer(0.05).timeout
		scale_target = Vector2(1,1)
		dashing = false
	if dashing:
		velocity.x = prev_dir * 7000
	
	scale = scale.move_toward(scale_target,0.09)
	move_and_slide()
