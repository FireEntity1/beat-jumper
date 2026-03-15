extends Node2D

var title = "Title"
var songs = []

var parent: Node2D

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update(new_title, new_songs):
	title = new_title
	songs = new_songs
	for child in $scroll/vbox.get_children():
		child.queue_free()
	$title.text = title
	for song in songs:
		var button = Button.new()
		var data = load_map_data(song.map)
		if data != null:
			button.text = data.name
			button.add_theme_font_size_override("font_size",64)
			button.connect("button_down",play.bind(song.song))
			button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			$scroll/vbox.add_child(button)

func play(song):
	parent.play(song)

func load_map_data(path):
	if path == null:
		return
	if not FileAccess.file_exists(path):
		return null
	var dir = FileAccess.open(path,FileAccess.READ)
	var text = dir.get_as_text()
	var data = JSON.parse_string(text)
	dir.close()
	data.erase("data")
	return data
