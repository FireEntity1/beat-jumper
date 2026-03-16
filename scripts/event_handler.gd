extends Node2D

@export var is_preview = false

var event_types = {
	"laser": preload("res://components/laser.tscn"),
	"laser_circle": preload("res://components/laser_circle.tscn"),
	"laser_sweep": preload("res://components/laser_sweep.tscn"),
	"laser_spread": preload("res://components/laser_spread.tscn"),
	"laser_slam": preload("res://components/laser_slam.tscn")
	}
@export var bpm: float = 118
var beat = 0.0
var last_beat = 0.0

var manual_last_beat = 0.0

var bpm_changes = []

var event_index = 0

var event_classes = {
	"movable": ["laser", "laser_circle", "laser_sweep", "laser_spread","laser_slam"],
	"screen_effect": ["shake", "glitch","platform_colour", "camera_kick"]
}

var beat_running = false

var target_platform_colour = global.colours_raw["pink"]
var platform_colour_speed = 1
var showing_sun = false
var sun_mult = 0.0

#var map: Dictionary = global.default_map.duplicate(true)

var map = {"artist":"trung-nova","audiofilename":"song.ogg","bpm":166.0,"data":[{"beat":0.0,"intensity":0.5,"status":true,"type":"vhs"},{"amount":"24","beat":2.0,"colour":["pink"],"direction":true,"distance":300.0,"outwards":false,"pos":[0.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"beat":7.0,"colour":"pink","pos":[3.0,1.0],"rot":50.0,"type":"laser"},{"beat":7.5,"colour":"pink","pos":[7.0,1.0],"rot":-65.0,"type":"laser"},{"beat":8.0,"colour":"pink","pos":[1.0,3.0],"rot":-10.0,"type":"laser"},{"beat":9.0,"colour":"pink","pos":[7.0,3.0],"rot":40.0,"type":"laser"},{"beat":10.0,"colour":"pink","pos":[1.0,1.0],"rot":110.0,"type":"laser"},{"beat":10.5,"colour":"pink","pos":[7.0,1.0],"rot":-45.0,"type":"laser"},{"beat":11.0,"colour":"pink","pos":[1.0,3.0],"rot":270.0,"type":"laser"},{"beat":11.5,"colour":"pink","pos":[9.0,1.0],"rot":225.0,"type":"laser"},{"beat":12.0,"colour":"pink","pos":[3.0,2.0],"rot":20.0,"type":"laser"},{"beat":13.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":14.0,"colour":"pink","pos":[2.0,1.0],"rot":25.0,"type":"laser"},{"beat":15.0,"colour":"pink","pos":[3.0,1.0],"rot":15.0,"type":"laser"},{"beat":16.0,"colour":"pink","pos":[1.0,1.0],"rot":50.0,"type":"laser"},{"beat":17.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":18.0,"colour":"pink","pos":[1.0,3.0],"rot":80.0,"type":"laser"},{"beat":18.5,"colour":"pink","pos":[8.0,1.0],"rot":-70.0,"type":"laser"},{"beat":19.0,"colour":"pink","pos":[7.0,4.0],"rot":55.0,"type":"laser"},{"beat":19.5,"colour":"pink","pos":[4.0,3.0],"rot":-25.0,"type":"laser"},{"beat":20.0,"colour":"pink","pos":[1.0,3.0],"rot":25.0,"type":"laser"},{"beat":21.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":22.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":23.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":24.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":24.6666666666667,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":25.3333333333333,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":26.5,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":27.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":78.0,"new_bpm":118.0,"type":"bpm_change"},{"beat":110.0,"speed":0.5,"status":true,"type":"camera_kick"},{"beat":120.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":122.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":126.0,"speed":0.25,"status":true,"type":"camera_kick"},{"beat":134.0,"speed":0.125,"status":true,"type":"camera_kick"},{"beat":134.5,"speed":0.25,"status":false,"type":"camera_kick"},{"beat":134.75,"speed":0.125,"status":true,"type":"camera_kick"},{"beat":135.25,"speed":0.25,"status":false,"type":"camera_kick"},{"beat":135.5,"speed":0.125,"status":true,"type":"camera_kick"},{"beat":136.0,"speed":0.25,"status":false,"type":"camera_kick"},{"beat":136.25,"speed":0.125,"status":true,"type":"camera_kick"},{"beat":136.75,"speed":0.25,"status":false,"type":"camera_kick"},{"beat":137.0,"speed":0.125,"status":true,"type":"camera_kick"},{"beat":138.0,"speed":0.25,"status":false,"type":"camera_kick"},{"beat":142.0,"speed":0.5,"status":true,"type":"camera_kick"},{"beat":162.0,"new_bpm":118.0,"type":"bpm_change"},{"beat":162.0,"rot":-15.0,"speed":1.9,"type":"cam_zoom","zoom":4.0},{"beat":163.0,"rot":15.0,"speed":1.0,"type":"cam_zoom","zoom":4.0},{"beat":164.0,"rot":-15.0,"speed":1.0,"type":"cam_zoom","zoom":4.0},{"beat":165.0,"rot":15.0,"speed":1.0,"type":"cam_zoom","zoom":3.7},{"beat":166.0,"rot":0.0,"speed":6.9,"type":"cam_zoom","zoom":4.0},{"beat":166.5,"colour":"pink","length":0.25,"pos":[6.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":166.5,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":166.5,"colour":"pink","length":0.25,"pos":[4.0,1.0],"rot":0.0,"type":"laser_slam"},{"amount":"16","beat":167.0,"colour":["pink","red"],"direction":1.0,"edges":12.0,"pos":[1.0,3.0],"radius":400.0,"rot":0.0,"speed":0.5,"type":"laser_circle"},{"amount":"16","beat":167.0,"colour":["hotpink","pink","blue"],"direction":1.0,"edges":12.0,"pos":[9.0,1.0],"radius":400.0,"rot":0.0,"speed":0.5,"type":"laser_circle"},{"beat":167.0,"intensity":0.5,"length":1.0,"type":"glitch"},{"amount":12.0,"beat":174.5,"colour":["hotpink","purple"],"direction":true,"distance":300.0,"outwards":true,"pos":[4.0,1.0],"rot":120.0,"speed":0.00390625,"type":"laser_sweep"},{"beat":175.0,"intensity":0.5,"length":0.0,"type":"glitch"},{"amount":24.0,"beat":179.5,"colour":["pink"],"direction":1.0,"edges":3.0,"pos":[5.0,3.0],"radius":241.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":179.5,"rot":0.0,"speed":6.9,"type":"cam_zoom","zoom":1.22},{"beat":179.875,"rot":-5.0,"speed":6.3,"type":"cam_zoom","zoom":1.38},{"amount":24.0,"beat":179.875,"colour":["green"],"direction":1.0,"edges":4.0,"pos":[5.0,3.0],"radius":301.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":24.0,"beat":180.25,"colour":["orange"],"direction":1.0,"edges":5.0,"pos":[5.0,3.0],"radius":301.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":180.25,"rot":1.0,"speed":7.0,"type":"cam_zoom","zoom":0.84},{"amount":24.0,"beat":180.5,"colour":["orange"],"direction":1.0,"edges":6.0,"pos":[5.0,3.0],"radius":391.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":180.75,"rot":0.0,"speed":6.3,"type":"cam_zoom","zoom":1.42},{"amount":24.0,"beat":180.875,"colour":["blue"],"direction":1.0,"edges":7.0,"pos":[5.0,3.0],"radius":481.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":24.0,"beat":181.25,"colour":["hotpink"],"direction":1.0,"edges":8.0,"pos":[5.0,3.0],"radius":491.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":181.25,"rot":-5.0,"speed":6.3,"type":"cam_zoom","zoom":1.64},{"amount":24.0,"beat":181.625,"colour":["purple"],"direction":1.0,"edges":9.0,"pos":[5.0,3.0],"radius":511.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":181.75,"rot":-1.0,"speed":6.3,"type":"cam_zoom","zoom":1.82},{"amount":24.0,"beat":182.0,"colour":["green"],"direction":1.0,"edges":9.0,"pos":[5.0,3.0],"radius":601.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":182.25,"rot":-3.0,"speed":6.3,"type":"cam_zoom","zoom":1.98},{"amount":12.0,"beat":182.5,"colour":["hotpink","red"],"direction":true,"distance":300.0,"outwards":true,"pos":[5.0,1.0],"rot":90.0,"speed":0.125,"type":"laser_sweep"},{"beat":182.625,"rot":0.0,"speed":6.7,"type":"cam_zoom","zoom":0.82},{"amount":"36","beat":183.5,"colour":["hotpink","pink","blue","green","red","purple","orange"],"direction":"-17","edges":12.0,"pos":[5.0,2.0],"radius":400.0,"rot":0.0,"speed":0.0625,"type":"laser_circle"},{"beat":183.75,"rot":0.0,"speed":5.5,"type":"cam_zoom","zoom":1.32},{"beat":186.5,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":258.5,"intensity":0.5,"status":false,"type":"vhs"},{"beat":258.5,"colour":"pink","length":0.0,"pos":[5.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":258.75,"colour":"pink","length":0.0,"pos":[9.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":259.0,"colour":"pink","length":0.0,"pos":[2.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":259.5,"colour":"pink","length":0.0,"pos":[6.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":259.75,"colour":"pink","length":0.0,"pos":[2.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":260.25,"colour":"pink","length":0.0,"pos":[6.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":260.5,"colour":"pink","length":0.0,"pos":[2.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":261.0,"colour":"pink","length":0.0,"pos":[2.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":261.25,"colour":"pink","length":0.0,"pos":[9.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":261.75,"colour":"pink","length":0.0,"pos":[6.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":262.0,"colour":"pink","length":0.0,"pos":[2.0,1.0],"rot":0.0,"type":"laser_slam"},{"amount":"16","beat":262.5,"colour":["hotpink","pink","blue","green","red","purple","orange","white"],"direction":"-1","edges":12.0,"pos":[0.0,5.0],"radius":81.0,"rot":0.0,"speed":0.5,"type":"laser_circle"},{"amount":"16","beat":262.5,"colour":["hotpink","pink","blue","green","red","purple","orange","white"],"direction":1.0,"edges":12.0,"pos":[10.0,5.0],"radius":91.0,"rot":0.0,"speed":0.5,"type":"laser_circle"},{"amount":"8","beat":270.5,"colour":["hotpink","pink","blue","green","red","purple"],"direction":"-1","edges":12.0,"pos":[1.0,3.0],"radius":181.0,"rot":0.0,"speed":0.25,"type":"laser_circle"},{"amount":"8","beat":270.5,"colour":["hotpink","pink","blue","green","red","purple"],"direction":1.0,"edges":12.0,"pos":[9.0,3.0],"radius":181.0,"rot":0.0,"speed":0.25,"type":"laser_circle"},{"amount":"8","beat":272.5,"colour":["pink"],"direction":1.0,"edges":12.0,"pos":[8.0,1.0],"radius":400.0,"rot":0.0,"speed":0.125,"type":"laser_circle"},{"amount":"8","beat":273.5,"colour":["pink"],"direction":"-1","edges":12.0,"pos":[3.0,1.0],"radius":400.0,"rot":240.0,"speed":0.125,"type":"laser_circle"},{"amount":"16","beat":278.5,"colour":["pink","red"],"direction":true,"distance":531.0,"outwards":true,"pos":[1.0,1.0],"rot":50.0,"speed":0.0625,"type":"laser_sweep"},{"amount":"16","beat":279.5,"colour":["blue","red"],"direction":false,"distance":531.0,"outwards":true,"pos":[10.0,1.0],"rot":-50.0,"speed":0.0625,"type":"laser_sweep"},{"beat":280.5,"intensity":2.0,"status":true,"type":"chromabb"},{"amount":"18","beat":280.5,"colour":["red"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":261.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":"18","beat":281.0,"colour":["pink","blue","purple"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":301.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":"18","beat":281.5,"colour":["pink","blue","purple"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":461.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":"18","beat":282.0,"colour":["pink","blue","purple"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":681.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":"16","beat":282.5,"colour":["red","orange"],"direction":true,"distance":531.0,"outwards":true,"pos":[1.0,1.0],"rot":50.0,"speed":0.0625,"type":"laser_sweep"},{"beat":282.5,"intensity":1.0,"status":false,"type":"chromabb"},{"amount":"16","beat":283.5,"colour":["hotpink","blue"],"direction":false,"distance":531.0,"outwards":true,"pos":[10.0,1.0],"rot":-50.0,"speed":0.0625,"type":"laser_sweep"},{"amount":"18","beat":284.5,"colour":["red"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":261.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":284.5,"intensity":2.0,"status":true,"type":"chromabb"},{"amount":"18","beat":285.0,"colour":["pink","blue","purple"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":301.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":"18","beat":285.5,"colour":["pink","blue","purple"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":461.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":"18","beat":286.0,"colour":["pink","blue","purple"],"direction":1.0,"edges":5.0,"pos":[5.0,2.0],"radius":681.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":286.5,"intensity":1.0,"status":false,"type":"chromabb"},{"beat":606.5,"colour":"pink","length":3.0,"pos":[3.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":606.5,"colour":"pink","length":3.0,"pos":[8.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":606.5,"intensity":0.5,"length":3.0,"type":"glitch"},{"amount":12.0,"beat":609.5,"colour":["pink"],"direction":true,"distance":300.0,"outwards":true,"pos":[1.0,1.0],"rot":90.0,"speed":0.03125,"type":"laser_sweep"},{"amount":12.0,"beat":610.5,"colour":["blue"],"length":3.0,"pos":[5.0,0.0],"rot":0.0,"speed":3.0,"type":"laser_spread"},{"amount":12.0,"beat":610.5,"colour":["orange"],"length":4.0,"pos":[7.0,0.0],"rot":0.0,"speed":3.0,"type":"laser_spread"},{"beat":610.5,"intensity":0.5,"length":4.0,"type":"glitch"},{"amount":256.0,"beat":671.0,"colour":["purple"],"direction":1.0,"edges":5.0,"pos":[1.0,1.0],"radius":281.0,"rot":0.0,"speed":0.5,"type":"laser_circle"},{"amount":12.0,"beat":799.0,"colour":["pink"],"direction":1.0,"edges":12.0,"pos":[1.0,1.0],"radius":400.0,"rot":0.0,"speed":0.00390625,"type":"laser_circle"},{"amount":12.0,"beat":799.25,"colour":["pink"],"direction":1.0,"edges":12.0,"pos":[1.0,1.0],"radius":400.0,"rot":0.0,"speed":0.00390625,"type":"laser_circle"},{"amount":12.0,"beat":799.75,"colour":["pink"],"direction":1.0,"edges":12.0,"pos":[1.0,1.0],"radius":400.0,"rot":0.0,"speed":0.00390625,"type":"laser_circle"},{"beat":831.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":833.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"},{"beat":835.0,"colour":"pink","pos":[1.0,1.0],"rot":0.0,"type":"laser"}],"imagename":"image.png","name":"Roars of Vengeance","offset":0.0,"preview_start":0.0,"sub":"","version":1.0}

func _ready() -> void:
	map.data = sanitize_json(map.data,true)
	bpm = float(map.bpm)
	bpm_changes = get_bpm_changes()
	if not is_preview:
		await get_tree().create_timer(3).timeout
		$music.play(0)
		await get_tree().create_timer(map.offset).timeout
		beat_running = true
	map.data.sort_custom(sort_by_trigger_beat)
	$main_platform/platform_sprite.modulate = global.colours_raw["purple"]
	global.bpm = bpm
	global.apply_prefire()

func _process(delta: float) -> void:
	global.bpm = bpm
	if not is_preview:
		last_beat = beat
		if $music.playing and beat_running:
			beat = time_to_beat($music.get_playback_position()) 
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
				global.bpm = bpm
				global.apply_prefire()
				bpm_changes = get_bpm_changes()
				map.data.sort_custom(sort_by_trigger_beat)
				event_index = 0
				for e in map.data:
					if e["beat"] - global.prefire_beat[e["type"]] < beat:
						event_index += 1
					else:
						break
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
						temp.rot = event.rot
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
		bpm_changes = get_bpm_changes()
		
	event_index = 0
	reset_states()
	
	map.data.sort_custom(sort_by_trigger_beat)
	
	for event in map.data:
		if event["beat"] - global.prefire_beat[event["type"]] < new_beat:
			event_index += 1
		else:
			break
	if playing:
		beat = new_beat
		$music.play(time)
	else:
		$music.stop()

func reset_states():
	$player.position = Vector2(0,0)
	platform_colour_speed = 1
	showing_sun = false
	global.visualizer = true
	global.cam_zoom = 1.0
	global.cam_rot = 0.0
	global.shake = false
	global.camera_kick = false

func click():
	$click.play()

func sanitize_json(array: Array, to_vector: bool):
	var sanitized = array.duplicate(true)
	for event in sanitized:
		if event.has("pos"):
			if to_vector and event.pos is Array:
				event.pos = Vector2(event.pos[0],event.pos[1])
			elif not to_vector and event.pos is Vector2:
				event.pos = [event.pos.x,event.pos.y]
	return sanitized

func load_map(dir: String):
	if FileAccess.file_exists(dir.path_join("map.jump")):
		var map_string = FileAccess.get_file_as_string(dir.path_join("map.jump"))
		map = JSON.parse_string(map_string)
		sanitize_json(map.data,true)
	if FileAccess.file_exists(dir.path_join("song.ogg")):
		var song_path = dir.path_join("song.ogg")
		var song = AudioStreamOggVorbis.load_from_file(song_path)
		$song.stream = song
	print(map)

func _on_border_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		body.hit()
		body.position = Vector2(0,0)

func time_to_beat(time: float):
	time -= map.offset
	var elapsed = 0.0
	for i in range(bpm_changes.size()):
		var cur = bpm_changes[i]
		var next_beat = (
			bpm_changes[i+1].beat
			if i+1 < bpm_changes.size()
			else INF
		)
		var segment_time = (next_beat - cur.beat) * (60.0/cur.new_bpm)
		if elapsed + segment_time >= time:
			return cur.beat + (time - elapsed) * (cur.new_bpm/60.0)
		elapsed += segment_time
	return bpm_changes[-1].beat

func get_bpm_changes() -> Array:
	var changes = []
	for event in map.data:
		if event.type == "bpm_change":
			changes.append(event)
	changes.sort_custom(func(a,b): return a.beat < b.beat)
	if changes.is_empty() or changes[0].beat > 0:
		changes.push_front({"type":"bpm_change","beat":0.0,"new_bpm":map.bpm})
	return changes
