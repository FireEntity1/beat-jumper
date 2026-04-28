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

var fade = true

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

var map = {"artist":"fireentity","audiofilename":"song.ogg","bpm":150.0,"data":[{"beat":0.0,"intensity":0.0,"status":true,"type":"vhs"}],"imagename":"image.png","name":"FRACTURED//ANOMALY","offset":0.04,"preview_start":0.0,"sub":"","version":1.0}

func _ready() -> void:
	if global.selected_song.has("map"):
		load_map(global.selected_song.map.get_base_dir())
		#global.selected_map = {}
	map.data = sanitize_json(map.data,true)
	bpm = float(map.bpm)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	bpm_changes = get_bpm_changes()
	$main_platform/platform_sprite.modulate = global.colours_raw["black"]
	if not is_preview:
		await get_tree().create_timer(1.0).timeout
		fade = false
		await get_tree().create_timer(2.0).timeout
		$music.play(0)
		await get_tree().create_timer(map.offset).timeout
		beat_running = true
	map.data.sort_custom(sort_by_trigger_beat)
	global.bpm = bpm
	global.apply_prefire()

func _process(delta: float) -> void:
	global.bpm = bpm
	if fade:
		$fade/fade.modulate.a = lerpf($fade/fade.modulate.a,1.0,delta*2)
	else:
		$fade/fade.modulate.a = lerpf($fade/fade.modulate.a,0.0,delta*2)
	if not is_preview:
		last_beat = beat
		if $music.playing and beat_running:
			beat = time_to_beat($music.get_playback_position()) 
	else:
		fade = false
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
		#$parallax/backlit_particles.emitting = false
		#$parallax/backlit_particles.hide()
	
	$parallax/sun.material.set_shader_parameter("color_main",Color(
					$main_platform/platform_sprite.modulate.r*sun_mult,
					$main_platform/platform_sprite.modulate.g*sun_mult,
					$main_platform/platform_sprite.modulate.b*sun_mult
				))
	
	while event_index < map.data.size():
		var event = map.data[event_index]
		var trigger_beat = event["beat"] - global.prefire_beat[event["type"]]
		if crossed(last_beat, beat, trigger_beat) or (trigger_beat < last_beat):
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
			elif event.type == "cam_zoom":
				global.cam_rot = event.rot
				global.cam_speed = event.speed
				global.cam_zoom = event.zoom
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
				global.shake_changed.emit(event.intensity if event.status else 0.0)
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
				global.vhs_changed.emit(event.status, event.intensity)
				event_index += 1
				continue
			elif event.type == "chromabb":
				global.chromabb = event.status
				global.chromabb_intensity = event.intensity * 6.0
				global.chromabb_changed.emit(event.status, event.intensity * 6.0)
				event_index += 1
				continue
			elif event.type == "glitch":
				glitch_timeout(event.length)
				global.glitch_intensity = event.intensity
				global.glitch_changed.emit(true, event.intensity)
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
					if event.has("move"):
						temp.move = event.move
					if event.has("hold"):
						temp.fire_hold = float(event.hold)
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
	var trigger_a = a["beat"] - global.prefire_beat.get(a["type"], 0.0)
	var trigger_b = b["beat"] - global.prefire_beat.get(b["type"], 0.0)
	return trigger_a < trigger_b

func timeout_sun(time):
	showing_sun = true
	await get_tree().create_timer((60.0/bpm)*time).timeout
	showing_sun = false

func glitch_timeout(time):
	global.glitch = true
	await get_tree().create_timer((60.0/bpm)*time).timeout
	global.glitch = false
	global.glitch_changed.emit(false, 0.0)

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
		if event.has("amount"):
			event.amount = int(event.amount)
	return sanitized

func load_map(dir: String):
	if FileAccess.file_exists(dir.path_join("map.jump")):
		var map_string = FileAccess.get_file_as_string(dir.path_join("map.jump"))
		map = JSON.parse_string(map_string)
		sanitize_json(map.data,true)
	if FileAccess.file_exists(dir.path_join("song.ogg")):
		var song_path = dir.path_join("song.ogg")
		var song = AudioStreamOggVorbis.load_from_file(song_path)
		$music.stream = song

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


func _on_music_finished() -> void:
	if not is_preview:
		fade = true
		global.damage = $player.hits
		await get_tree().create_timer(3).timeout
		get_tree().change_scene_to_file("res://scenes/score.tscn")
