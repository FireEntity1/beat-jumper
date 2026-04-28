extends Node2D

var fade = true

func _ready() -> void:
	global.add_hover_press_effect($enter,true,false)
	await get_tree().create_timer(0.2).timeout
	fade = false

func _process(delta: float) -> void:
	if not fade:
		$fade.color.a = lerpf($fade.color.a, 0,delta*10)
	else:
		$fade.color.a = lerpf($fade.color.a, 1,delta*10)

func _on_enter_button_up() -> void:
	$click.play()
	fade = true
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")
