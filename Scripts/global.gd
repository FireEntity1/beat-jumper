extends Node

var song_data: Dictionary = {}
var song
var hits = 0
var demo = false
var settings = {
	"volume": 10
}

func set_song_data(data: Dictionary):
	song_data = data

func get_song_data() -> Dictionary:
	return song_data

func setSong(stream: AudioStreamOggVorbis):
	print("Song set")
	song = stream

func getSong() -> AudioStreamOggVorbis:
	print("Retrived song")
	return song

func setDemo(val):
	demo = true

func getDemo():
	return demo

func hit():
	hits += 1

func getHits():
	return hits

func changeVolume(value):
	settings.volume = value

func getVolume():
	return settings.volume

func resetHealth():
	hits = 0
