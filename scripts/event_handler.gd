extends Node2D

@export var is_preview = false

var event_types = {
	"laser": preload("res://components/laser.tscn"),
	"laser_circle": preload("res://components/laser_circle.tscn"),
	"laser_sweep": preload("res://components/laser_sweep.tscn"),
	"laser_spread": preload("res://components/laser_spread.tscn"),
	"laser_slam": preload("res://components/laser_slam.tscn")
	}
var epsilon = 0.000000001
@export var bpm: float = 118
var beat = 0.0
var last_beat = 0.0

var manual_last_beat = 0.0

var event_index = 0

var event_classes = {
	"movable": ["laser", "laser_circle", "laser_sweep", "laser_spread","laser_slam"],
	"screen_effect": ["shake", "glitch","platform_colour", "camera_kick"]
}

var target_platform_colour = global.colours_raw["pink"]
var platform_colour_speed = 1
var showing_sun = false
var sun_mult = 0.0

var map: Dictionary = global.default_map.duplicate(true)

func _ready() -> void:
	bpm += epsilon
	if not is_preview:
		$music.play(0)
	map.data.sort_custom(sort_by_trigger_beat)
	$main_platform/platform_sprite.modulate = global.colours_raw["purple"]

func _process(delta: float) -> void:
	global.bpm = bpm
	if not is_preview:
		last_beat = beat
		beat += (bpm/60.0)*delta
	global.beat = beat
	global.current_col = $main_platform/platform_sprite.modulate
	$main_platform/platform_sprite.modulate.r = move_toward($main_platform/platform_sprite.modulate.r,target_platform_colour[0],delta*platform_colour_speed)
	$main_platform/platform_sprite.modulate.g = move_toward($main_platform/platform_sprite.modulate.g,target_platform_colour[1],delta*platform_colour_speed)
	$main_platform/platform_sprite.modulate.b = move_toward($main_platform/platform_sprite.modulate.b,target_platform_colour[2],delta*platform_colour_speed)
	#var weight = 1.0 - exp(-1.0 * delta)
	if showing_sun:
		sun_mult = move_toward(sun_mult,7,delta*100)
		$sun_blocker.position.y = move_toward($sun_blocker.position.y,242,delta*4000)
		$parallax/backlit_particles.emitting = true
		#$parallax/backlit_particles.show()
	else:
		#sun_mult = move_toward(sun_mult,0,delta*100)
		$sun_blocker.position.y = move_toward($sun_blocker.position.y,-1500,delta*4000)
		$parallax/backlit_particles.emitting = false
		$parallax/backlit_particles.hide()
	
	$parallax/sun.material.set_shader_parameter("color_main",Color(
					$main_platform/platform_sprite.modulate.r*sun_mult,
					$main_platform/platform_sprite.modulate.g*sun_mult,
					$main_platform/platform_sprite.modulate.b*sun_mult
				))
	
	while event_index < map.data.size():
		var event = map.data[event_index]
		var trigger_beat = event["beat"] - global.prefire_beat[event["type"]]
		if crossed(last_beat,beat,trigger_beat):
			var temp
			if event.type == "platform_colour":
				target_platform_colour = global.colours_raw[event.colour]
				platform_colour_speed = event.speed
				event_index += 1
				continue
			elif event.type == "sun":
				timeout_sun(event.length)
				event_index += 1
				continue
			elif event.type == "camera_kick":
				global.camera_kick = event.status
				global.camera_kick_speed = event.speed
				event_index += 1
				continue
			elif event.type == "shake":
				global.shake = event.status
				global.shake_intensity = event.intensity
				event_index += 1
				continue
			elif event.type == "visualizer":
				global.visualizer = event.status
				global.visualizer_line = event.line
				global.visualizer_smooth = event.smooth_line
				global.visualizer_bar = event.bar
				event_index += 1
				continue
			elif event.type == "vhs":
				global.vhs = event.status
				global.vhs_intensity = event.intensity
				event_index += 1
				continue
			elif event.type == "chromabb":
				global.chromabb = event.status
				global.chromabb_intensity = event.intensity
				event_index += 1
				continue
			elif event.type == "glitch":
				glitch_timeout(event.length)
				global.glitch_intensity = event.intensity
				event_index += 1
				continue
			elif event.type == "cam_zoom":
				global.cam_rot = event.rot
				global.cam_speed = event.speed
				global.cam_zoom = event.zoom
				event_index += 1
				continue
			elif event.type == "bpm_change":
				bpm = event.new_bpm
				event_index += 1
				continue
			elif event.type in event_types:
				temp = event_types[event.type].instantiate()
				temp.fire_beat = event.beat
				if event.type in event_classes.movable:
					temp.pos = event.pos
					temp.rot = event.rot
				match event.type:
					"laser":
						temp.colour = event.colour
					"laser_circle":
						temp.speed = event.speed
						temp.radius = event.radius
						temp.edges = event.edges
						temp.amount = event.amount
						temp.colour = event.colour
						temp.direction = event.direction
					"laser_sweep":
						temp.speed = event.speed
						temp.amount = event.amount
						temp.distance = event.distance
						temp.outwards = event.outwards
						temp.colour = event.colour
						temp.direction = event.direction
					"laser_spread":
						temp.speed = event.speed
						temp.colour = event.colour
						temp.amount = event.amount
						temp.length = event.length
					"laser_slam":
						temp.colour = event.colour
						temp.fire_hold = event.length
						temp.rot = 0
				$events.add_child(temp)
				event_index += 1
			
		else:
			break
	
func crossed(prev: float, now: float, target: float):
	return prev <= target and now >= target

func sortbeat(a,b):
	return a["beat"] < b["beat"]

func sort_by_trigger_beat(a, b):
	var trigger_a = a["beat"] - global.prefire_beat[a["type"]]
	var trigger_b = b["beat"] - global.prefire_beat[b["type"]]
	return trigger_a < trigger_b

func timeout_sun(time):
	showing_sun = true
	await get_tree().create_timer((60.0/bpm)*time).timeout
	showing_sun = false

func glitch_timeout(time):
	global.glitch = true
	await get_tree().create_timer((60.0/bpm)*time).timeout
	global.glitch = false

func modify(playing: bool, time: float, new_beat: float, new_map: Dictionary = {},new_bpm: float = bpm):
	bpm = new_bpm
	for event in $events.get_children():
		event.queue_free()
	if new_map.has("data"):
		map = new_map.duplicate(true)
		
	event_index = 0
	reset_states()
	
	map.data.sort_custom(sort_by_trigger_beat)
	
	for event in map.data:
		if event.beat < new_beat:
			event_index += 1
		else:
			break
	if playing:
		beat = new_beat
		$music.play(time)
	else:
		0
		$music.stop()

func reset_states():
	$player.position = Vector2(0,0)
	target_platform_colour = global.colours_raw.purple
	platform_colour_speed = 1
	showing_sun = false
	global.visualizer = true
	global.shake = false
	global.camera_kick = false

func click():
	$click.play()
