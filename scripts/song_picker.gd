extends Node2D

const SONG_CATEGORY = preload("res://components/song_category.tscn")

@onready var picker = $song_category

var selected: Dictionary
var popup = false

var back = {
	"pressed": false,
	"hover": false
}

var fade = true

var categories = {
	"ALL SONGS": [],
	"OST 1": [
		{
			"song": preload("res://ost/ost1/fractured--anomaly/song.ogg"),
			"map": "res://ost/ost1/fractured--anomaly/map.jump",
			"image": preload("res://ost/ost1/fractured--anomaly/cover.png")
		},
		{
			"song": preload("res://ost/ost1/fractured--anomaly/song.ogg"),
			"map": "res://ost/ost1/fractured--anomaly/map.jump",
			"image": preload("res://sprites/icon.png")
		}
	],
	"EXTRAS": [
		{
			"song": null,
			"map": null
		}
	]
}

func _ready() -> void:
	global.add_hover_press_effect($back)
	$fade/fade.show()
	popup = false
	var i = 0
	for key in categories:
		var button = Button.new()
		button.text = key
		button.connect("button_down",spawn_category_view.bind(key))
		button.add_theme_font_size_override("font_size", 48)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		#button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		button.custom_minimum_size.x = 200
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.theme = preload("res://resources/title.tres")
		global.add_hover_press_effect(button)
		$categories/vbox.add_child(button)
		await get_tree().process_frame
		button.pivot_offset = button.size / 2
		global.add_hover_press_effect(button,false,true)
	global.add_hover_press_effect($play)
	spawn_category_view("ALL SONGS")
	await get_tree().create_timer(0.2).timeout
	select(categories["ALL SONGS"][0])
	fade = false

func _process(delta: float) -> void:
	if not fade:
		$fade/fade.color.a = lerpf($fade/fade.color.a, 0,delta*10)
	else:
		$fade/fade.color.a = lerpf($fade/fade.color.a, 1,delta*10)
	if popup:
		$play.position.x = lerpf($play.position.x,610.0,delta*10)
		$play.position.y = lerpf($play.position.y,400.0,delta*10)
		$play.size.x = lerpf($play.size.x,730,delta*10)
		$play.size.y = lerpf($play.size.y,256.0,delta*10)
		$play.add_theme_font_size_override("font_size",lerp($play.get_theme_font_size("font_size"),175,delta*10))
		$blur.material.set_shader_parameter("blur_strength",
		lerpf($blur.material.get_shader_parameter("blur_strength"),3.0,delta*10))
		$blur.material.set_shader_parameter("darken",
		lerpf($blur.material.get_shader_parameter("darken"),0.625,delta*10))
	else:
		$play.position.x = lerpf($play.position.x,1284.0,delta*10)
		$play.position.y = lerpf($play.position.y,819.0,delta*10)
		$play.size.x = lerpf($play.size.x,486.0,delta*10)
		$play.size.y = lerpf($play.size.y,171.0,delta*10)
		$play.add_theme_font_size_override("font_size",lerp($play.get_theme_font_size("font_size"),125,delta*10))
		$blur.material.set_shader_parameter("blur_strength",
		lerpf($blur.material.get_shader_parameter("blur_strength"),0.0,delta*10))
		$blur.material.set_shader_parameter("darken",
		lerpf($blur.material.get_shader_parameter("darken"),0.0,delta*10))
	if Input.is_action_just_pressed("escape"):
		$blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
		popup = false

func spawn_category_view(category):
	picker.parent = self
	if not category == "ALL SONGS":
		picker.update(category, categories[category])
	else:
		var all_songs = []
		for key in categories:
			for song in categories[key]:
				all_songs.push_back(song)
				print(song)
		categories["ALL SONGS"] = all_songs
		picker.update(category, all_songs)

func play(song):
	$songpreview.stream = song
	$songpreview.play()

func _on_back_button_down() -> void:
	back.pressed = true
	fade = true
	$back.release_focus()
	await get_tree().create_timer(0.1).timeout
	back.pressed = false
	await get_tree().create_timer(0.8).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_back_mouse_entered() -> void:
	back.hover = true

func _on_back_mouse_exited() -> void:
	back.hover = false

func select(map):
	var loaded_map = load_map_data(map.map)
	selected = map
	print(loaded_map)
	$preview_title.text = loaded_map.name
	$preview_artist.text = loaded_map.artist
	$bpm.text = str(int(loaded_map.bpm)) + " BPM"
	$duration.text = str(floori(map.song.get_length()/60)) + ":" + str(int(map.song.get_length())%60)
	$cover.texture = map.image

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

func _on_play_button_up() -> void:
	print(selected)
	if selected.has("map") and not popup:
		popup = true
		$blur.mouse_filter = Control.MOUSE_FILTER_STOP
	elif popup:
		global.selected_song = selected
		await get_tree().create_timer(0.1).timeout
		fade = true
		await get_tree().create_timer(0.8).timeout
		get_tree().change_scene_to_file("res://scenes/main_game.tscn")


func _on_blur_gui_input(event: InputEvent) -> void:
	print("CLICKED")
	if event is InputEventMouseButton and event.pressed and popup:
		$blur.mouse_filter = Control.MOUSE_FILTER_IGNORE
		popup = false
