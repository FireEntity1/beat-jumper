extends Node2D
var running = true
var active = false
var bpm = Global.get_song_data().bpm
var hit = false
var end = false

func _ready():
	self.modulate.a = 0
	self.modulate.r = 0
	self.modulate.g = 1
	self.modulate.b = 1
	$fireTimer.wait_time = 1/(bpm/60)*2
	$fireTimer.start()
	$area.connect("body_entered", Callable(self, "_player_entered"))
	$area.connect("body_exited", Callable(self, "_player_exited"))
	$area/collision.shape.size = Vector2(25,25)
	self.scale.x = 1


func _process(delta):
	if running:
			self.modulate.a += delta
		
	if active and hit:
		Global.hit()
		hit = false
	
	if active:
		self.modulate.r = 1
		self.modulate.g = 1
		self.modulate.b = 1
		if $area/Laser.scale.x < 10:
			$area/Laser.scale.x += 40*delta
		$fireTimer.wait_time = 1/(bpm/60)
		
		if self.modulate.a > 0.5:
			self.modulate.a -= 6.5*delta
		else:
			active = false
			end = true
	
	if end:
		if self.modulate.a > 0:
			self.modulate.a -= 6.5*delta
		else:
			queue_free()

func _on_fire_timer_timeout():
	active = true
	running = false
	self.modulate.a = 1

func _player_entered(body):
	if body is CharacterBody2D:
		hit = true

func _player_exited(body):
	if body is CharacterBody2D:
		hit = false
