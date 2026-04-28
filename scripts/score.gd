extends Node2D

var fade = true

var damage: int = 0
var rank = "SS"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	damage = global.damage
	global.returning = true
	global.add_hover_press_effect($exit,true,false)
	$rank_val.text = generate_rank(damage)
	$damage_num.text = str(damage)
	if damage == 0:
		$damage_num.text = "NO HIT"
	await get_tree().create_timer(0.2).timeout
	$uiclick.play()
	fade = false

func _process(delta: float) -> void:
	if not fade:
		$fade.color.a = lerpf($fade.color.a, 0,delta*10)
	else:
		$fade.color.a = lerpf($fade.color.a, 1,delta*10)

func generate_rank(damage):
	if damage == 0:
		$rank_val.add_theme_color_override("font_color",Color(1.8,1.8,1.8))
		$damage_num.add_theme_color_override("font_color",Color(1.8,1.8,1.8))
		return "SS+"
	elif 1 <= damage and damage <= 2:
		$rank_val.add_theme_color_override("font_color",Color(1.3,1.3,1.6))
		$damage_num.add_theme_color_override("font_color",Color(1.3,1.3,1.6))
		return "SS"
	elif 3 <= damage and damage <= 5:
		$rank_val.add_theme_color_override("font_color",Color(1.3,1.3,1.6))
		$damage_num.add_theme_color_override("font_color",Color(1.3,1.3,1.6))
		return "S"
	elif 6 <= damage and damage <= 10:
		$rank_val.add_theme_color_override("font_color",Color(1.3,1.8,1.3))
		$damage_num.add_theme_color_override("font_color",Color(1.3,1.8,1.3))
		return "A"
	elif 11 <= damage and damage <= 20:
		$rank_val.add_theme_color_override("font_color",Color(1.7,1.7,1.2))
		$damage_num.add_theme_color_override("font_color",Color(1.7,1.7,1.2))
		return "B"
	elif 21 <= damage and damage <= 30:
		$rank_val.add_theme_color_override("font_color",Color(1.8,1.4,1.2))
		$damage_num.add_theme_color_override("font_color",Color(1.8,1.4,1.2))
		return "C"
	else:
		$rank_val.add_theme_color_override("font_color",Color(1.8,1.2,1.2))
		$damage_num.add_theme_color_override("font_color",Color(1.8,1.2,1.2))
		return "F"

func _on_exit_button_up() -> void:
	fade = true
	$click.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/song_picker.tscn")
