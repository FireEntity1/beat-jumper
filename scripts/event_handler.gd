extends Node2D

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

var event_index = 0

var event_classes = {
	"movable": ["laser", "laser_circle", "laser_sweep", "laser_spread","laser_slam"],
	"screen_effect": ["shake", "glitch","platform_colour", "camera_kick"]
}

var target_platform_colour = global.colours_raw["pink"]
var platform_colour_speed = 1
var showing_sun = false
var sun_mult = 0.0

var events = [
	{
		"type": "visualizer",
		"beat": 4,
		"status": false
	},
	{
		"type": "laser_circle",
		"beat": 0+4,
		"pos": Vector2(4,3),
		"rot": 0,
		"radius": 400,
		"amount": 12,
		"edges": 12,
		"speed": 1.0/6.0,
		"colour": ["pink","red"],
		"direction": 1
	},
	{
		"type": "laser_circle",
		"beat": 2+4,
		"pos": Vector2(7,3),
		"rot": 90,
		"radius": 400,
		"amount": 12,
		"edges": 12,
		"speed": 1.0/6.0,
		"colour": ["purple","blue"],
		"direction": -1
	},
	{
		"type": "platform_colour",
		"beat": 4,
		"colour": "black",
		"speed": 10
	},
	{
		"type": "visualizer",
		"beat": 4+4,
		"status": true
	},
	{
		"type": "bpm_change",
		"beat": 8,
		"new_bpm": 500
	},
	{
		"type": "platform_colour",
		"beat": 4+3,
		"colour": "pink",
		"speed": 5
	},
	{
		"type": "laser",
		"beat": 15,
		"pos": Vector2(5,5.2),
		"rot": 0,
		"colour": "orange"
	},
	{
		"type": "laser",
		"beat": 15.4,
		"pos": Vector2(5,4.8),
		"rot": 0,
		"colour": "purple"
	},
	{
		"type": "platform_colour",
		"beat": 4+4,
		"colour": "pink",
		"speed": 50
	},
	{
		"type": "laser_sweep",
		"beat": 11,
		"pos": Vector2(5,1),
		"rot": 90,
		"amount": 16,
		"speed": 1.0/16.0,
		"distance": 300,
		"outwards": true,
		"colour": ["pink"]
	},
	{
		"type": "laser_slam",
		"beat": 8,
		"pos": Vector2(3,1),
		"rot": 0,
		"colour": "pink",
		"length": 3.0
	},
	{
		"type": "laser_slam",
		"beat": 8,
		"pos": Vector2(9,1),
		"rot": 0,
		"colour": "pink",
		"length": 3.0
	},
	{
		"type": "glitch",
		"beat": 4+4,
		"length": 3,
		"strength": 0.5
	},
	{
		"type": "platform_colour",
		"beat": 7+4,
		"colour": "black",
		"speed": 10
	},
	{
		"type": "platform_colour",
		"beat": 8+4,
		"colour": "blue",
		"speed": 50
	},
	{
		"type": "laser_spread",
		"beat": 8+4,
		"colour": ["blue"],
		"speed": 3,
		"amount": 10,
		"length": 4.0,
		"pos": Vector2(5,0),
		"rot": 0
	},
	{
		"type": "laser_spread",
		"beat": 8+4,
		"colour": ["blue"],
		"speed": 3,
		"amount": 10,
		"length": 4.0,
		"pos": Vector2(7,3),
		"rot": 0
	},
	{
		"type": "glitch",
		"beat": 8+4,
		"length": 4,
		"strength": 0.5
	},
	{
		"type": "platform_colour",
		"beat": 12+4,
		"colour": "black",
		"speed": 5
	},
	{
		"type": "visualizer",
		"beat": 12+4,
		"status": false
	},
	
]

func _ready() -> void:
	bpm += epsilon
	#$music.play(310.4)
	$music.play(279.55)
	events.sort_custom(sort_by_trigger_beat)
	$main_platform/platform_sprite.modulate = global.colours_raw["purple"]

func _process(delta: float) -> void:
	global.bpm = bpm
	last_beat = beat
	beat += (bpm/60)*delta
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
	
	while event_index < events.size():
		var event = events[event_index]
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
				global.shake_strength = event.strength
				event_index += 1
				print("shake set to ", event.status, " strength: ", event.strength)
				continue
			elif event.type == "visualizer":
				global.visualizer = event.status
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
				global.glitch_strength = event.strength
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
					"laser_spread":
						temp.speed = event.speed
						temp.colour = event.colour
						temp.amount = event.amount
						temp.length = event.length
					"laser_slam":
						temp.colour = event.colour
						temp.fire_hold = event.length
						temp.rot = 0
				add_child(temp)
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
