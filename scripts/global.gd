extends Node

var path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS).path_join("lightbound-data")

var bpm = 120
var beat = 0
var last_beat = 0
var grid_mult = Vector2(275,160)
var grid_offset = Vector2(-1660,-670)

var visualizer = true
var visualizer_line = false
var visualizer_smooth = true
var visualizer_bar = true

signal shake_changed(intensity)
signal glitch_changed(active, intensity)
signal chromabb_changed(active, intensity)
signal vhs_changed(active, intensity)

var vhs = false
var vhs_intensity = 0.5

var settings = {
	"volume": -40
}

var chromabb = false
var chromabb_intensity = 0.0

var camera_kick = false
var camera_kick_speed = 1.0

var current_col: Color

var glitch = false
var glitch_intensity = 1

var cam_zoom = 1.0
var cam_rot = 0.0
var cam_speed = 1.0

var shake = false
var shake_intensity = 0.5

var selected_song = {}

var damage = 0

var returning = false

var prefire_sec = {
	"laser": 0.6,
	"laser_circle": 0.6,
	"laser_sweep": 0.6,
	"laser_spread": 0.6,
	"laser_slam": 0.6,
	
	"platform_colour": 0.0,
	"sun": 0.0,
	"camera_kick": 0.0,
	"shake": 0.0,
	"visualizer": 0.0,
	"vhs": 0.0,
	"chromabb": 0.0,
	"glitch": 0.0,
	"cam_zoom": 0.0,
	
	"bpm_change": 0.0
}

var prefire_beat = {
	"laser": prefire_sec.laser * (bpm / 60.0),
	"laser_circle": prefire_sec.laser_circle * (bpm / 60.0),
	"laser_sweep": prefire_sec.laser_sweep * (bpm / 60.0),
	"laser_spread": prefire_sec.laser_spread * (bpm / 60.0),
	"laser_slam": prefire_sec.laser_slam * (bpm / 60.0),
	
	"platform_colour": 0,
	"sun": prefire_sec.sun * 0,
	"camera_kick": prefire_sec.camera_kick * 0,
	"shake": 0,
	"visualizer": 0,
	"vhs": 0,
	"chromabb": 0,
	"glitch": 0,
	"cam_zoom": 0,
	
	"bpm_change": 0,
}

const multicolor = ["laser_circle","laser_spread","laser_sweep"]

const defaults = {
	"laser": {
		"type": "laser",
		"beat": 0,
		"pos": Vector2(1,1),
		"rot": 0,
		"colour": "pink",
		"move": {
			"enabled": false,
			"speed": 1000,
			"ease": 0.0,
			"always": false,
			"dir_x": 0.0,
			"dir_y": 1.0,
			"focus": false,
		},
		"hold": 0.0
	},
	"laser_circle": {
		"type": "laser_circle",
		"beat": 0,
		"pos": Vector2(1,1),
		"rot": 0,
		"radius": 400,
		"amount": 24,
		"edges": 12,
		"speed": 1.0/8.0,
		"colour": ["pink"],
		"direction": 1
	},
	"laser_sweep": {
		"type": "laser_sweep",
		"beat": 0,
		"pos": Vector2(1,1),
		"rot": 90,
		"amount": 12,
		"speed": 1.0/8.0,
		"distance": 300,
		"direction": true,
		"outwards": true,
		"colour": ["pink"]
	},
	"laser_slam": {
		"type": "laser_slam",
		"beat": 0,
		"pos": Vector2(5,1),
		"rot": 0,
		"colour": "pink",
		"length": 4.0
	},
	"laser_spread": {
		"type": "laser_spread",
		"beat": 0,
		"colour": ["pink"],
		"speed": 3,
		"amount": 12,
		"length": 4.0,
		"pos": Vector2(5,0),
		"rot": 0
	},
	"platform_colour": {
		"type": "platform_colour",
		"beat": 0,
		"colour": "pink",
		"speed": 5
	},
	"sun": {
		"type": "sun",
		"beat": 0,
		"length": 1
	},
	"camera_kick": {
		"type": "camera_kick",
		"beat": 0,
		"status": true,
		"speed": 1.0/4.0
	},
	"shake": {
		"type": "shake",
		"beat": 0,
		"status": true,
		"intensity": 0.5
	},
	"visualizer": {
		"type": "visualizer",
		"beat": 0,
		"status": true,
		"line": false,
		"smooth_line": true,
		"bar": true
	},
	"vhs": {
		"type": "vhs",
		"beat": 0,
		"status": true, 
		"intensity": 0.5
	},
	"chromabb": {
		"type": "chromabb",
		"beat": 0,
		"status": true,
		"intensity": 1.0,
	},
	"glitch": {
		"type": "glitch",
		"beat": 0,
		"length": 4,
		"intensity": 0.5
	},
	"cam_zoom": {
		"type": "cam_zoom",
		"beat": 0,
		"zoom": 1.0,
		"rot": 0.0,
		"speed": 1.0
	},
	"bpm_change": {
		"type": "bpm_change",
		"beat": 0,
		"new_bpm": 120.0
	}
}

const default_map = {
	"name": "New Map",
	"bpm": 120.0,
	"artist": "Artist",
	"sub": "",
	"imagename": "image.png",
	"audiofilename": "song.ogg",
	"version": 1,
	"offset": 0.0,
	
	"preview_start": 0,
	"data": []
}

const colours = {
	"red": [9,4,4],
	"orange": [9,7,2],
	"green": [5,8,5],
	"blue": [5,8,8],
	"pink": [8,4,8],
	"hotpink": [9,2,7],
	"purple": [6,3,9],
	"white": [7,7,7],
	"black": [0,0,0]
}

const colours_raw = {
	"hotpink": Color(3,1,2.5),
	"pink": Color(2.4,1.5,1.5),
	"blue": Color(1,3,3),
	"green": Color(1.3,2.3,1.3),
	"red": Color(3,1,1.5),
	"purple": Color(2,1,3),
	"orange": Color(3,2,1),
	"white": Color(3,3,3),
	"black": Color(0.0,0.0,0.0)
}

const MULTICOLOUR = ["laser_circle", "laser_spread", "laser_sweep"]

func _ready() -> void:
	apply_prefire()
	create_map_dir()

func _process(delta: float) -> void:
	pass

func apply_grid(value: Vector2):
	return (value*grid_mult) + grid_offset

func apply_prefire():
	for key in prefire_beat:
		prefire_beat[key] = prefire_sec[key] * (bpm / 60.0)

func create_map_dir():
	if not DirAccess.dir_exists_absolute(path):
		DirAccess.make_dir_recursive_absolute(path)
		DirAccess.make_dir_recursive_absolute(path.path_join("wip"))
		DirAccess.make_dir_recursive_absolute(path.path_join("maps"))

#func add_hover_press_effect(node: Control, horizontal = false, vertical = false, scale_amt = 1.0) -> void:
	#var tween: Tween
	#
	#node.mouse_entered.connect(func():
		#if tween: tween.kill()
		#tween = node.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		#tween.tween_property(node, "scale", Vector2(1.25*scale_amt if not vertical else 1.0, 1.0 if horizontal else 1.25*scale_amt), 0.5))
	#
	#node.mouse_exited.connect(func():
		#if tween: tween.kill()
		#tween = node.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		#tween.tween_property(node, "scale", Vector2(1.0, 1.0), 0.5)
	#)
	#
	#node.gui_input.connect(func(event: InputEvent):
		#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			#node.release_focus()
			#if tween: tween.kill()
			#tween = node.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			#if event.pressed:
				#tween.tween_property(node, "scale", Vector2(0.9*scale_amt, 0.9*scale_amt), 0.2)
			#else:
				#tween.tween_property(node, "scale", Vector2(1.15*scale_amt, 1.15*scale_amt), 0.4)
	#)
func add_hover_press_effect(node: Control, horizontal: bool = false, vertical: bool = false, scale_amt: float = 1.0, interact_scale = 1.0) -> void:
	var update_pivot = func(): node.pivot_offset = node.size / 2.0
	update_pivot.call()
	node.resized.connect(update_pivot)

	var state = {
		"tween": null,
		"hovered": false,
		"pressed": false
	}

	var hover_x = 1.0 if vertical else 1.25 * scale_amt
	var hover_y = 1.0 if horizontal else 1.25 * scale_amt
	var hover_scale = Vector2(hover_x, hover_y)
	var press_scale = Vector2(0.9 * scale_amt * interact_scale, 0.9 * scale_amt * interact_scale)

	var apply_animation = func():
		if state.tween: 
			state.tween.kill()
		
		state.tween = node.create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		
		var target_scale = Vector2.ONE
		var duration = 0.5
		
		if state.pressed:
			target_scale = press_scale
			duration = 0.2
		elif state.hovered:
			target_scale = hover_scale
			duration = 0.4
			
		state.tween.tween_property(node, "scale", target_scale, duration)

	node.mouse_entered.connect(func():
		state.hovered = true
		apply_animation.call()
	)
	
	node.mouse_exited.connect(func():
		state.hovered = false
		state.pressed = false
		apply_animation.call()
	)
	
	node.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				node.release_focus()
				state.pressed = true
			else:
				state.pressed = false
			
			apply_animation.call()
	)
