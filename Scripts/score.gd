extends Node2D



func _ready():
	var song_data = Global.get_song_data()
	var hit = Global.getHits()
	
	var total = 0
	for event in song_data.events:
		if event.type != "crtOn" and event.type != "crtOff" and event.type != "flash":
			total += 1
	var accuracy = float(total-hit)/float(total) * 100.0
	print(hit)
	print(total)
	print(total-hit)
	$acc.text = "Accuracy " + str(int(accuracy)) + "%"
	$dodged.text = "Dodged: " + str(total-hit) + "/" + str(total)
	$hit.text = "Hit: " + str(hit)
	Global.resetHealth()

func _process(delta):
	pass

func _on_confirm_button_up():
	$select.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/title.tscn")

func _on_confirm_mouse_entered():
	$click.play()
