extends Node2D
var running = true
var active = false
var bpm = Global.get_song_data().bpm

func _ready():
	self.modulate.a = 0
	$fireTimer.wait_time = 1/(bpm/60)*2
	$fireTimer.start()
	$area.connect("body_entered", Callable(self, "_player_entered"))


func _process(delta):
	if running:
			self.modulate.a += delta
	
	if active:
		if $area/Laser.scale.x < 10:
			$area/Laser.scale.x += 40*delta
		$fireTimer.wait_time = 1/(bpm/60)
		
		if self.modulate.a > 0:
			self.modulate.a -= 5*delta
		else:
			queue_free()

func _on_fire_timer_timeout():
	active = true
	running = false
	self.modulate.a = 1

func _player_entered(body):
	if body is CharacterBody2D:
		print("hit!")
