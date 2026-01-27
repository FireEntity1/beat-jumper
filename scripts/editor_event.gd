extends Button

var track: String
var beat: float

var event_data: Dictionary

func _ready() -> void:
	var i = 0
	for key in event_data:
		var label = Label.new()
		var editable = LineEdit.new()
		label.text = key + ": "
		editable.text = str(event_data[key])
		editable.connect("text_changed",_on_editable_changed)
		$edit/container.add_child(label)
		$edit/container.add_child(editable)
		if key == "length":
			custom_minimum_size.x = 300 * event_data.length

func _on_editable_changed(text: String):
	print(text)

func _process(delta: float) -> void:
	pass

func load_default(selected_track: String, beat: float):
	track = selected_track
	text = selected_track

func _on_button_up() -> void:
	$edit.popup()
