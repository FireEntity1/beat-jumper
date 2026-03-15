extends Node2D

var play = {
	"hover": false,
	"pressed": false
}

var editor = {
	"hover": false,
	"pressed": false
}

var title = false

func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if play["pressed"]:
		$play.scale.x = lerpf($play.scale.x,2.0,delta*5)
		$fade.color.a = lerpf($fade.color.a,1.0,delta*15)
		$play.scale.y = lerpf($play.scale.y,0.0,delta*10)
	elif play["hover"]:
		$play.scale.x = lerpf($play.scale.x,1.3,delta*10)
	else:
		$play.scale.x = lerpf($play.scale.x,1.0,delta*10)
	
	if editor["pressed"]:
		$editor.scale.x = lerpf($editor.scale.x,2.0,delta*5)
		$fade.color.a = lerpf($fade.color.a,1.0,delta*15)
		$editor.scale.y = lerpf($editor.scale.y,0.0,delta*10)
	elif editor["hover"]:
		$editor.scale.x = lerpf($editor.scale.x,1.3,delta*10)
	else:
		$editor.scale.x = lerpf($editor.scale.x,1.0,delta*10)
		
	if title:
		$title.scale.x = lerpf($title.scale.x, 0.56,delta*5)
		$title.scale.y = lerpf($title.scale.y, 0.56,delta*5)
		$title.position.y = lerpf($title.position.y,260,delta*5)
	else:
		$title.scale.x = lerpf($title.scale.x, 0.54,delta*5)
		$title.scale.y = lerpf($title.scale.y, 0.54,delta*5)
		$title.position.y = lerpf($title.position.y,244,delta*5)


# ts comments not ai i just want to be able to read my shitty code

# -------------------- PLAY BUTON --------------
func _on_play_mouse_entered() -> void:
	play.hover = true

func _on_play_mouse_exited() -> void:
	play.hover = false

func _on_play_button_down() -> void:
	play.pressed = true

# -------------------- EDITOR BUTON --------------
func _on_editor_button_down() -> void:
	editor.pressed = true
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://scenes/editor.tscn")

func _on_editor_mouse_entered() -> void:
	editor.hover = true

func _on_editor_mouse_exited() -> void:
	editor.hover = false


# -------------------- TITLE -----------------
func _on_control_mouse_entered() -> void:
	title = true

func _on_control_mouse_exited() -> void:
	title = false
