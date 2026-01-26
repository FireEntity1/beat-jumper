extends Button

var track: String
var beat: float

var event_data: Dictionary

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func load_default(selected_track: String, beat: float):
	track = selected_track
	text = selected_track


func _on_button_up() -> void:
	$edit.popup()
