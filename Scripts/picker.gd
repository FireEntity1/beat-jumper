extends Node2D

func _ready():
	$FileDialog.visible = true


func _process(delta):
	pass

func _on_file_dialog_dir_selected(dir: String):
	var json_as_text = FileAccess.get_file_as_string(dir + "/song.json")
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		Global.set_song_data(json_as_dict)
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
		var directory = DirAccess.open(dir)
		print(directory)
		var filename = directory.get_next()
		print(filename)
		while filename != "":
			print(filename)
			if filename.ends_with(".ogg"):
				load_ogg(dir + "/" + filename)
				print(dir + "/" + filename)
			filename = directory.get_next()
		load_ogg(dir + "/song.ogg")

func load_ogg(path):
	var sound = AudioStreamOggVorbis.load_from_file(path)
	Global.setSong(sound)
