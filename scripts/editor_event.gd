extends Button

const POS_EDITOR = preload("res://components/pos_picker.tscn")

var track: String
var beat: float

var pos_editor

var parent: Node2D

var event_data: Dictionary

var map_dir: String

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
				editable = ItemList.new()
				if event_data.type in global.MULTICOLOUR:
					editable.select_mode = ItemList.SELECT_MULTI
				for colour in global.colours:
					editable.add_item(colour)
				var selected = event_data.colour
				if selected is Array:
					for item in range(editable.item_count):
						if editable.get_item_text(item) in selected:
							editable.select(item,false)
				editable.custom_minimum_size.y = 200
				editable.connect("multi_selected",_on_colour_selected.bind(editable))
			"speed":
				editable = LineEdit.new()
				editable.text = str(event_data[key])
				editable.connect("text_changed", _on_speedpicker_changed)
			"length":
				editable = LineEdit.new()
				editable.text = str(event_data[key])
				editable.connect("text_changed", _on_length_changed)
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
				editable.value = event_data.radius
				editable.min_value = 1
				editable.max_value = 1000
				editable.step = 10
				editable.tick_count = 11
				editable.connect("value_changed", _radius_value_changed)
			"distance":
				editable = HSlider.new()
				editable.value = event_data.distance
				editable.min_value = 1
				editable.max_value = 1000
				editable.step = 10
				editable.tick_count = 11
				editable.connect("value_changed", _distance_value_changed)
			"intensity":
				editable = HSlider.new()
				editable.value = event_data.intensity
				editable.min_value = 0.0
				editable.max_value = 2.0
				editable.step = 0.05
				editable.tick_count = 21
				editable.connect("value_changed", _intensity_value_changed)
			_:
				if key == "type":
					continue
				if event_data[key] is bool:
					editable = CheckBox.new()
					editable.button_pressed = event_data[key]
					editable.connect("toggled",_on_editable_changed.bind(key))
				else:
					editable = LineEdit.new()
					editable.text = str(event_data[key])
					editable.connect("text_changed",_on_editable_changed.bind(key))
		if key != "rot":
			$edit/container.add_child(label)
			$edit/container.add_child(editable)
		if key == "length":
			custom_minimum_size.x = 300 * float(event_data.length)

func _on_editable_changed(data,key: String):
	var old = event_data.duplicate(true)
	match key:
		"new_bpm":
			event_data[key] = float(data)
		"status":
			event_data[key] = data
		_:
			event_data[key] = data
	if pos_editor is Control:
		pos_editor.update_preview()
	parent.modify(old,event_data)

func _on_speedpicker_changed(text):
	var old = event_data
	var exp = Expression.new()
	var regex = RegEx.new()
	regex.compile(r"\b(\d+)\b")
	text = regex.sub(text,"$1.0", true)
	if exp.parse(str(text)) == OK:
		var value = exp.execute()
		event_data.speed = value
	else:
		print("error")
	parent.modify(old,event_data)

func _on_length_changed(text):
	var old = event_data
	var exp = Expression.new()
	var regex = RegEx.new()
	regex.compile(r"\b(\d+)\b")
	text = regex.sub(text,"$1.0", true)
	if exp.parse(str(text)) == OK:
		var value = exp.execute()
		event_data.length = value
		print(value)
	else:
		print("error")
	parent.modify(old,event_data)

func _edges_value_changed(value):
	var old = event_data
	event_data.edges = value
	pos_editor.event_data = event_data
	pos_editor.update_preview()
	parent.modify(old,event_data)

func _radius_value_changed(value):
	var old = event_data
	event_data.radius = value
	pos_editor.event_data = event_data
	pos_editor.update_preview()
	parent.modify(old,event_data)

func _distance_value_changed(value):
	var old = event_data
	event_data.distance = value
	pos_editor.event_data = event_data
	pos_editor.update_preview()
	parent.modify(old,event_data)

func _on_colour_selected(index: int, selected: bool, list: ItemList):
	var old = event_data
	var cols = []
	for i in list.get_selected_items():
		cols.append(list.get_item_text(i))
	event_data.colour = cols
	parent.modify(old,event_data)

func _intensity_value_changed(value: float):
	var old = event_data
	event_data.intensity = value
	parent.modify(old,event_data)

func _process(delta: float) -> void:
	pass

func load_default(selected_track: String, beat: float):
	track = selected_track
	text = selected_track

func _gui_input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and not Input.is_action_pressed("shift"):
			$edit.popup()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			parent.delete(event_data)
			queue_free()
			accept_event()

func _on_button_up() -> void:
	return
	if not Input.is_action_pressed("shift") and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$edit.popup()
	elif Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		parent.delete(event_data)
		queue_free()

func load_map(name: String = ""):
	return
