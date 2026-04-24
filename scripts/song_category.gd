extends Node2D

const SONG_ITEM = preload("res://components/song_item.tscn")

var title = "Title"
var songs = []

var selected: Node2D

var parent: Node2D

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

func update(new_title, new_songs):
	title = new_title
	songs = new_songs
	for child in $scroll/vbox.get_children():
		child.queue_free()
	$title.text = title
	for song in songs:
		var song_item = SONG_ITEM.instantiate()
		global.add_hover_press_effect(song_item.get_node("play"),true,false,0.9,1.3)
		$scroll/vbox.add_child(song_item)
		
		var data = load_map_data(song.map)
		if data != null:
			var cover = song_item.get_node("cover")
			cover.texture = song.image
			song_item.get_node("name").text = data.name
			song_item.get_node("artist").text = data.artist
			song_item.song = song

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
