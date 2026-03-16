extends Node2D

const SONG_CATEGORY = preload("res://components/song_category.tscn")

@onready var picker = $song_category

var back = {
	"pressed": false,
	"hover": false
}

var fade = true

var categories = {
	"OST 1": [
		{
			"song": preload("res://ost/ost1/doorless_room/song.ogg"),
			"map": "res://ost/ost1/doorless_room/map.jump",
			"image": preload("res://ost/ost1/doorless_room/cover.jpg")
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
	$fade/fade.show()
	var i = 0
	for key in categories:
		var button = Button.new()
		button.text = key
		button.connect("button_down",spawn_category_view.bind(key))
		button.add_theme_font_size_override("font_size", 36)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.alignment = HORIZONTAL_ALIGNMENT_CENTER
		$categories/vbox.add_child(button)
	await get_tree().create_timer(0.5).timeout
	fade = false

func _process(delta: float) -> void:
	if not fade:
		$fade/fade.color.a = lerpf($fade/fade.color.a, 0,delta*5)
	else:
		$fade/fade.color.a = lerpf($fade/fade.color.a, 1,delta*5)
	
	if back["pressed"]:
		$back.scale.x = lerpf($back.scale.x,0.5,delta*5)
		$back.scale.y = lerpf($back.scale.y,0.5,delta*5)
	elif back["hover"]:
		$back.scale.x = lerpf($back.scale.x,1.3,delta*10)
		$back.scale.y = lerpf($back.scale.y,1.3,delta*10)
	else:
		$back.scale.x = lerpf($back.scale.x,1.0,delta*10)
		$back.scale.y = lerpf($back.scale.y,1.0,delta*10)

func spawn_category_view(category):
	picker.parent = self
	picker.update(category, categories[category])

func play(song):
	$songpreview.stream = song
	$songpreview.play()


func _on_back_button_down() -> void:
	back.pressed = true
	fade = true
	$back.release_focus()
	await get_tree().create_timer(0.1).timeout
	back.pressed = false
	await get_tree().create_timer(1.2).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _on_back_mouse_entered() -> void:
	back.hover = true

func _on_back_mouse_exited() -> void:
	back.hover = false
