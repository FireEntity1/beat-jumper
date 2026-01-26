extends Node2D

const TRACK = preload("res://components/track.tscn")

var map: Dictionary
var selection: Array

var cursor: float


func _ready() -> void:
	for event in global.defaults:
		var track = TRACK.instantiate()
		var name:String = global.defaults[event].type
		name = name.replace("_"," ")
		track.change_name(name)
		$scroll/tracks.add_child(track)

func _process(delta: float) -> void:
	pass
