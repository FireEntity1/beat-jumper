extends Node2D
var songdata = Global.get_song_data()
var bpm = songdata.bpm
var beat = 0

var hits = 0
var isName = true

var isGlitch = false


var centerL = preload("res://Scenes/centerL.tscn")
var rightL = preload("res://Scenes/rightL.tscn")
var leftL = preload("res://Scenes/leftL.tscn")
var bottomL = preload("res://Scenes/bottomL.tscn")
var middleL = preload("res://Scenes/middleL.tscn")
var topL = preload("res://Scenes/topL.tscn")
var diagL = preload("res://Scenes/diagL.tscn")
var diagR = preload("res://Scenes/diagR.tscn")

func _ready():
	$bpm.wait_time = (1/(bpm/60))/2
	$bpm.start()
	$songplayer.stream = Global.getSong()
	$songplayer.play()
	$crt.material.set_shader_parameter("screen_resolution", Vector2(0,0))
	$crt.material.set_shader_parameter("scanline_intensity", 0)
	$crt.material.set_shader_parameter("color_bleed_weight", 0)
	$CanvasLayer/name.modulate.a = 0
	$CanvasLayer/name/songName.text = songdata.name
	isName = true
	await get_tree().create_timer(3).timeout
	isName = false
	
	
func _process(delta):
	if hits != Global.getHits():
		hitAnim()
		hits = Global.getHits()
	if isName:
		if $CanvasLayer/name.modulate.a <= 1:
			$CanvasLayer/name.modulate.a += delta
	else:
		if $CanvasLayer/name.modulate.a >= 0:
			$CanvasLayer/name.modulate.a -= delta
	
func hitAnim():
	$hit.play()
	$ColorRect.color = Color(0.08,0.04,0,0.92)
	await get_tree().create_timer(0.4).timeout
	$ColorRect.color = Color(0,0,0,0.92)
	
func _on_bpm_timeout():
	beat += 0.5
	for n in songdata.events:
		if n.type == "crtOn" or n.type== "crtOff" or n.type == "flash":
			if n.beat == beat:
				if n.type == "crtOn":
					$crt.material.set_shader_parameter("screen_resolution", Vector2(DisplayServer.window_get_size().x,DisplayServer.window_get_size().y/8))
					$crt.material.set_shader_parameter("scanline_intensity", 0.5)
					$crt.material.set_shader_parameter("color_bleed_weight", 0.5)
					$glitch.material.set_shader_parameter("shake_power", 0.05)
					$glitch.material.set_shader_parameter("shake_color_rate", 0.02)
					isGlitch = true
				if n.type == "crtOff":
					$crt.material.set_shader_parameter("screen_resolution", Vector2(0,0))
					$crt.material.set_shader_parameter("scanline_intensity", 0)
					$crt.material.set_shader_parameter("color_bleed_weight", 0)
					$glitch.material.set_shader_parameter("shake_power", 0)
					$glitch.material.set_shader_parameter("shake_color_rate", 0)
					isGlitch = false
				if n.type == "flash":
					$ColorRect.color = Color(0,0,0,0.88)
					await get_tree().create_timer(0.1).timeout
					$ColorRect.color = Color(0,0,0,0.92)
		if n.beat == beat+2:
			match n.type:
				"rightL":
					var instance = rightL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"leftL":
					var instance = leftL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"centerL":
					var instance = centerL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"bottomL":
					var instance = bottomL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"middleL":
					var instance = middleL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"topL":
					var instance = topL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"topL":
					var instance = topL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"diagR":
					var instance = diagR.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()
				"diagL":
					var instance = diagL.instantiate()
					$laserContainer.add_child(instance)
					#tempGlitch()

func tempGlitch():
	if not isGlitch:
		await get_tree().create_timer((1/(bpm/60))*2).timeout
		$glitch.material.set_shader_parameter("shake_power", 0.01)
		await get_tree().create_timer(0.1).timeout
		$glitch.material.set_shader_parameter("shake_power", 0)
