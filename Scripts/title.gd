extends Node2D

func _ready():
	pass

func _process(delta):
	pass

func _on_demo_button_up():
	var demoData = FileAccess.get_file_as_string("res://DEMO/song.json")
	demoData = JSON.parse_string(demoData)
	Global.set_song_data(demoData)
	Global.setSong(AudioStreamOggVorbis.load_from_file("res://DEMO/song.ogg"))
	
	$select.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://Scenes/main.tscn")

func _on_load_button_up():
	$select.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://Scenes/songpicker.tscn")

func _on_editor_button_up():
	$select.play()
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://Scenes/editor.tscn")

func _on_demo_mouse_entered():
	$click.play()

func _on_load_mouse_entered():
	$click.play()

func _on_editor_mouse_entered():
	$click.play()


func _on_settings_button_up():
	$settingsWindow.popup_centered()


func _on_vol_value_changed(value):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),(-1/value)*15)
	$select.play()
