extends Node2D
var songdata = Global.get_song_data()
var bpm = songdata.bpm
var beat = 0
var centerL = preload("res://Scenes/centerL.tscn")
var rightL = preload("res://Scenes/rightL.tscn")
var leftL = preload("res://Scenes/leftL.tscn")

func _ready():
	$bpm.wait_time = (1/(bpm/60))/2
	$bpm.start()
	$songplayer.stream = Global.getSong()
	$songplayer.play()

func _process(delta):
	pass
	
func _on_bpm_timeout():
	beat += 0.5
	for n in songdata.events:
		if n.beat == beat:
			match n.type:
				"rightL":
					var instance = rightL.instantiate()
					add_child(instance)
					break
				"leftL":
					var instance = leftL.instantiate()
					add_child(instance)
					break
				"centerL":
					var instance = centerL.instantiate()
					add_child(instance)
					break
			
	for n in songdata.events:
		if n.beat == beat+2:
			print("warning!")
