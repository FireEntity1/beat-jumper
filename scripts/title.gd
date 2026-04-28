extends Node2D

var play = {
	"hover": false,
	"pressed": false
}

var editor = {
	"hover": false,
	"pressed": false
}

var quit = {
	"hover": false,
	"pressed": false,
	"done": false
}

var fade_music = false

var fade_active = false
var startup_fade = true

var title = false

func _ready() -> void:
	global.visualizer = true
	global.add_hover_press_effect($play,true)
	global.add_hover_press_effect($editor,true)
	global.add_hover_press_effect($quit,true)
	global.add_hover_press_effect($settings_menu/close,true,false)
	global.add_hover_press_effect($settings,true,true)
	$title.position.y = 800
	$title.scale = Vector2(1.2,1.2)
	await get_tree().create_timer(0.4).timeout
	$settings_menu/volume.value = global.volume
	$titlemusic.play(24)
	await get_tree().create_timer(0.4).timeout
	fade_active = true
	
	await get_tree().create_timer(1.2).timeout
	startup_fade = false

func _process(delta: float) -> void:
	if not fade_music:
		$titlemusic.volume_db = lerpf($titlemusic.volume_db,-11.667,delta*2)
	else:
		$titlemusic.volume_db = lerpf($titlemusic.volume_db,-40.0,delta*2)
	if $fade.color.a >= 0.2 or $fadeback.color.a >= 0.2:
		$fade.mouse_filter = Control.MOUSE_FILTER_STOP
	else:
		$fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	if not editor.pressed and not play.pressed and not quit.pressed and fade_active:
		$fade.color.a = lerpf($fade.color.a,0.0,delta*2)
	#
	if play["pressed"]:
		#$play.scale.x = lerpf($play.scale.x,2.0,delta*5)
		$fade.color.a = lerpf($fade.color.a,1.0,delta*15)
		#$play.scale.y = lerpf($play.scale.y,0.0,delta*10)
	#elif play["hover"]:
		#$play.scale.x = lerpf($play.scale.x,1.3,delta*10)
	#else:
		#$play.scale.x = lerpf($play.scale.x,1.0,delta*10)
	#
	#if editor["pressed"]:
		#$editor.scale.x = lerpf($editor.scale.x,2.0,delta*5)
		#$fade.color.a = lerpf($fade.color.a,1.0,delta*15)
		#$editor.scale.y = lerpf($editor.scale.y,0.0,delta*10)
	#elif editor["hover"]:
		#$editor.scale.x = lerpf($editor.scale.x,1.3,delta*10)
	#else:
		#$editor.scale.x = lerpf($editor.scale.x,1.0,delta*10)
		
	if title:
		$title.scale.x = lerpf($title.scale.x, 0.93,delta*5)
		$title.scale.y = lerpf($title.scale.y, 0.93,delta*5)
		$title.position.y = lerpf($title.position.y,254,delta*5)
	else:
		$title.scale.x = lerpf($title.scale.x, 0.9,delta*5)
		$title.scale.y = lerpf($title.scale.y, 0.9,delta*5)
		$title.position.y = lerpf($title.position.y,244,delta*5)
	
	if quit["pressed"]:
		#$quit.scale.x = lerpf($quit.scale.x,2.0,delta*5)
		#$quit.scale.y = lerpf($quit.scale.y,0.0,delta*10)
		$title.scale.x = lerpf($title.scale.x,1.2,delta*10)
		$title.scale.y = lerpf($title.scale.y,1.2,delta*10)
		$title.position.y = lerpf($title.position.y,800,delta*5)
		$fadeback.color.a = lerpf($fadeback.color.a,1.0,delta*20)
		#
	#elif quit["hover"]:
		#$quit.scale.x = lerpf($quit.scale.x,1.3,delta*10)
	#elif not quit["hover"]:
		#$quit.scale.x = lerpf($quit.scale.x,1.0,delta*10)
	
	if startup_fade:
		$title.position.y = 500
		$title.scale = Vector2(1.2,1.2)
		$fadeback.color.a = 1.0
	elif not quit["pressed"]:
		$title.scale.x = lerpf($title.scale.x,0.9,delta*10)
		$title.scale.y = lerpf($title.scale.y,0.9,delta*10)
		$title.position.y = lerpf($title.position.y,244,delta*5)
		$fadeback.color.a = lerpf($fadeback.color.a,0.0,delta*5)
	
	if quit["done"]:
		fade_music = true
		$fade.color.a = lerpf($fade.color.a,1.0,delta*4)


# ts comments not ai i just want to be able to read my shitty code

# -------------------- PLAY BUTON --------------

func _on_play_button_down() -> void:
	fade_music = true
	$click.play()
	$click.pitch_scale = 1.2
	play.pressed = true
	await get_tree().create_timer(0.75).timeout
	get_tree().change_scene_to_file("res://scenes/song_picker.tscn")
	#get_tree().change_scene_to_file("res://scenes/main_game.tscn")

# -------------------- EDITOR BUTON --------------
func _on_editor_button_down() -> void:
	fade_active = true
	$click.play()
	$click.pitch_scale = 1.0
	editor.pressed = true
	play.pressed = true
	await get_tree().create_timer(0.75).timeout
	get_tree().change_scene_to_file("res://scenes/editor.tscn")


# -------------------- TITLE -----------------
func _on_control_mouse_entered() -> void:
	title = true

func _on_control_mouse_exited() -> void:
	title = false

# -------------------- QUIT -----------
func _on_quit_button_down() -> void:
	fade_active = true
	$click.play()
	$click.pitch_scale = 0.8
	quit.pressed = true
	await get_tree().create_timer(1.0).timeout
	quit.done = true
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()


func _on_settings_button_up() -> void:
	$click.play()
	$click.pitch_scale = 1.0
	$settings_menu.popup_centered()

func _on_volume_drag_ended(value_changed: bool) -> void:
	global.modify_settings($settings_menu/volume.value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), $settings_menu/volume.value)


func _on_close_button_up() -> void:
	$click.play()
	$settings_menu.hide()
