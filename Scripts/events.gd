extends Node2D
var songdata = Global.get_song_data()
var bpm = songdata.bpm
var beat = 0


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

func _process(delta):
	pass
	
func _on_bpm_timeout():
	beat += 0.5
	for n in songdata.events:
		if n.beat == beat+2:
			match n.type:
				"rightL":
					var instance = rightL.instantiate()
					add_child(instance)
				"leftL":
					var instance = leftL.instantiate()
					add_child(instance)
				"centerL":
					var instance = centerL.instantiate()
					add_child(instance)
				"bottomL":
					var instance = bottomL.instantiate()
					add_child(instance)
				"middleL":
					var instance = middleL.instantiate()
					add_child(instance)
				"topL":
					var instance = topL.instantiate()
					add_child(instance)
				"topL":
					var instance = topL.instantiate()
					add_child(instance)
				"diagR":
					var instance = diagR.instantiate()
					add_child(instance)
				"diagL":
					var instance = diagL.instantiate()
					add_child(instance)
		if n.type == "crtOn" or n.type== "crtOff":
			if n.beat == beat:
				if n.type == "crtOn":
					$crt.material.set_shader_parameter("screen_resolution", Vector2(DisplayServer.window_get_size().x,DisplayServer.window_get_size().y/8))
					$crt.material.set_shader_parameter("scanline_intensity", 0.5)
					$crt.material.set_shader_parameter("color_bleed_weight", 0.5)
				if n.type == "crtOff":
					$crt.material.set_shader_parameter("screen_resolution", Vector2(0,0))
					$crt.material.set_shader_parameter("scanline_intensity", 0)
					$crt.material.set_shader_parameter("color_bleed_weight", 0)
