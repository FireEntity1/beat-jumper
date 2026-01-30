extends Button

const POS_EDITOR = preload("res://components/pos_picker.tscn")

var track: String
var beat: float

var pos_editor

var event_data: Dictionary

func _ready() -> void:
	if event_data.has("colour"):
		var col_val = event_data["colour"]
		var target_col
		
		if typeof(col_val) == TYPE_ARRAY:
			target_col = col_val[0]
		else:
			target_col = col_val
		if global.colours_raw.has(target_col):
			modulate = global.colours_raw[target_col]
	var i = 0
	for key in event_data:
		var label = Label.new()
		var editable
		label.text = key + ": "
		match key:
			"colour":
				editable = OptionButton.new()
				for colour in global.colours:
					editable.add_item(colour)
				if global.defaults[event_data.type].colour is Array:
					print("jsdhf")
			"speed":
				editable = LineEdit.new()
				editable.text = str(event_data[key])
				editable.connect("text_changed", _on_speedpicker_changed)
			"pos":
				editable = POS_EDITOR.instantiate()
				pos_editor = editable
				editable.pos = event_data.pos
				editable.rot = event_data.rot
				editable.event_data = event_data
				editable.event_type = event_data.type
			"edges":
				editable = HSlider.new()
				editable.value = event_data.edges
				editable.min_value = 3
				editable.max_value = 20
				editable.step = 1
				editable.tick_count = 18
				editable.connect("value_changed", _edges_value_changed)
			"radius":
				editable = HSlider.new()
				editable.value = event_data.edges
				editable.min_value = 1
				editable.max_value = 1000
				editable.step = 10
				editable.tick_count = 11
				editable.connect("value_changed", _radius_value_changed)
			_:
				editable = LineEdit.new()
				editable.text = str(event_data[key])
				editable.connect("text_changed",_on_editable_changed)
		if key != "rot":
			$edit/container.add_child(label)
			$edit/container.add_child(editable)
		if key == "length":
			custom_minimum_size.x = 300 * event_data.length
func _on_editable_changed(text: String):
	print(text)

func _on_speedpicker_changed(text):
	var exp = Expression.new()
	var regex = RegEx.new()
	regex.compile(r"\b(\d+)\b")
	text = regex.sub(text,"$1.0", true)
	if exp.parse(str(text)) == OK:
		var value = exp.execute()
		print(value)
	else:
		print("error")

func _edges_value_changed(value):
	event_data.edges = value
	pos_editor.event_data = event_data
	pos_editor.update_preview()

func _radius_value_changed(value):
	event_data.radius = value
	pos_editor.event_data = event_data
	pos_editor.update_preview()

func _process(delta: float) -> void:
	pass

func load_default(selected_track: String, beat: float):
	track = selected_track
	text = selected_track

func _on_button_up() -> void:
	if not Input.is_action_pressed("shift"):
		$edit.popup()
