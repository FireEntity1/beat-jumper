extends Control

var event_type = "laser"

var dragging = false

var event_data: Dictionary

var pos: Vector2
var rot: float

@onready var knob = $angle

var circle_lasers = []

var angle = 0

func _ready() -> void:
	$hslider.value = floor(pos.x)
	$vslider.value = floor(pos.y)
	angle = rot
	$pointer.rotation_degrees = angle
	$angle.value = rotation_degrees+90
	update_preview()
	
	if event_type == "laser":
		$laser_preview.show()
	for child in get_children():
		if child is Control:
			child.focus_mode = Control.FOCUS_CLICK
			child.mouse_filter = Control.MOUSE_FILTER_STOP

func _process(delta: float) -> void:
	if dragging:
		update_preview()

func _on_angle_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_set_value_from_mouse(event.position)
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_set_value_from_mouse(event.position)
	update_preview()

func _set_value_from_mouse(pos:Vector2):
	var center = knob.size/2
	var dir = pos - center
	angle = rad_to_deg(dir.angle()) - 90
	angle = fmod(angle + 360, 360)
	knob.value = angle
	$pointer.rotation_degrees = angle + 90
	update_preview()

func update_preview():
	$laser_preview.position = Vector2($hslider.value*30-70,$vslider.value*30+90)
	$laser_preview.rotation_degrees = angle + 90
	for laser in circle_lasers:
		laser.queue_free()
	circle_lasers = []
	$circle_preview.position = Vector2($hslider.value*30,$vslider.value*30) + Vector2(100,100)
	if event_type == "laser_circle":
		for laser in range(event_data.edges):
			spawn_laser(laser,event_data.edges,event_data.direction,event_data.radius)
	$circle_preview.rotation_degrees = angle+90
func spawn_laser(index: int, edges: int, direction: int, radius: float):
	var step = 360.0 / edges
	var current_angle_deg = step * index * direction
	var current_angle_rad = deg_to_rad(current_angle_deg)
	
	var temp = ColorRect.new()
	temp.size = Vector2(200, 2)
	temp.position = Vector2.from_angle(current_angle_rad) * radius/10 - temp.size / 2
	temp.rotation_degrees = current_angle_deg + 90
	temp.pivot_offset = temp.size/2
	$circle_preview.add_child(temp)
	circle_lasers.append(temp)

func _on_update_timeout() -> void:
	update_preview()

func _on_slider_drag_started() -> void:
	dragging = true
func _on_slider_drag_ended(value_changed: bool) -> void:
	dragging = false
