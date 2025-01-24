extends Control

var song_data: Dictionary
var song: AudioStreamOggVorbis

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_load_button_up():
	$FileDialog.show()


func _on_file_dialog_file_selected(path: String):
	var directory = path.split("song.ogg")
	if (FileAccess.file_exists(directory[0]+"song.json")):
		song_data = JSON.parse_string(FileAccess.get_file_as_string(directory[0] + "song.json"))
		print("file found!")
		loadSong(directory[0]+"song.json")
	else:
		$notice.dialog_text = "Song not found"
		$notice.popup_centered()

func loadSong(path):
	$bpm.text = str(song_data.bpm)
	$name.text = song_data.name

func loadOgg(path):
	song = AudioStreamOggVorbis.load_from_file(path)
	return AudioStreamOggVorbis.load_from_file(path)

func _on_bpm_text_changed(new_text):
	song_data.bpm = float(new_text)


func _on_name_text_changed(new_text):
	song_data.name = new_text
