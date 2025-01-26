extends CharacterBody2D


const SPEED = 600.0
const JUMP_VELOCITY = -800.0
var jumps = 2

# states
var blur = false
var ended = true
var dashDir = 1
var dashReady = true
var landed = true
var jumped = false

func _ready():
	pass

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if self.position.y > 700:
		self.position.y = 325
		self.position.x = 0
		Global.hit()

	# handle jump and double jump !
	if Input.is_action_just_pressed("ui_up") and is_on_floor() and jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps = 1
		jumpSquish()
	elif Input.is_action_just_pressed("ui_up") and not is_on_floor() and jumps > 0:
		velocity.y = JUMP_VELOCITY
		jumps = 0
		jumpSquish()
	
	if blur and is_on_floor():
		landed = true
		$land.start()
		
	if landed:
		$playerSprite.scale.y = lerpf($playerSprite.scale.y,5,0.5)
		$playerSprite.scale.x = lerpf($playerSprite.scale.x,12,0.5)
		$playerSprite.position.y = 20
		landed = false
	else:
		$playerSprite.scale.y = lerpf($playerSprite.scale.y,8,0.2)
		$playerSprite.scale.x = lerpf($playerSprite.scale.x,8,0.2)
		$playerSprite.position.y = lerpf($playerSprite.position.y,0,0.2)
	
	if is_on_floor():
		jumps = 2
		blur = false;
		$playerSprite.scale.x = lerpf($playerSprite.scale.x,8,0.2)

	# ground slam
	if Input.is_action_just_pressed("ui_down") and not is_on_floor():
		velocity.y = -JUMP_VELOCITY*5
		blur = true
	
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		$playerSprite.scale.y = lerpf($playerSprite.scale.y,4,0.4)
		$playerSprite.position.y = lerpf($playerSprite.position.y,15,0.3)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if Input.is_action_just_pressed("ui_left"):
		$camera.rotation_degrees = -10
		$camera.position.x -= 80
	if Input.is_action_just_released("ui_left"):
		$camera.rotation_degrees = 0
		$camera.position.x += 80
		
	if Input.is_action_just_pressed("ui_right"):
		$camera.rotation_degrees = 10
		$camera.position.x += 80
	if Input.is_action_just_released("ui_right"):
		$camera.rotation_degrees = 0
		$camera.position.x -= 80
	
	if Input.is_action_just_pressed("dash") and dashReady:
		$dash.start()
		$dashCooldown.start()
		dashReady = false
		ended = false
		dashDir = direction
		
	if not ended:
		self.velocity.x = dashDir * 3500
		blur = true
		$playerSprite.scale.y = lerpf($playerSprite.scale.y,5,0.5)
		$playerSprite.scale.x = lerpf($playerSprite.scale.x,12,0.5)
	else:
		$playerSprite.scale.y = lerpf($playerSprite.scale.y,8,0.5)
	move_and_slide()
	
	if jumped:
		$playerSprite.scale.y = lerpf($playerSprite.scale.y,5,0.5)
		$playerSprite.scale.x = lerpf($playerSprite.scale.x,12,0.5)
	else:
		$playerSprite.scale.y = lerpf($playerSprite.scale.y,8,0.5)
	
	# motion blur !! i love motion blur
	var blur_dir
	if blur:
		blur_dir = Vector2(velocity.x/1500,velocity.y/1500)
	elif velocity.y > 0:
		blur_dir = Vector2(0,velocity.y/1500)
	else:
		blur_dir = Vector2(0,0)
	$playerSprite.material.set_shader_parameter("dir", blur_dir)


func _on_dash_timeout():
	ended = true
	blur = false


func _on_dash_cooldown_timeout():
	dashReady = true

func jumpSquish():
	jumped = true
	$jump.start()

func _on_jump_timeout():
	jumped = false
