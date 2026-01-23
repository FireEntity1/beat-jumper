extends Node2D

var event_types = {
	"laser": preload("res://components/laser.tscn"),
	"laser_circle": preload("res://components/laser_circle.tscn"),
	"laser_sweep": preload("res://components/laser_sweep.tscn")
	}
var epsilon = 0.000000001
@export var bpm: float = 118
var beat = 0.0
var last_beat = 0.0

var event_index = 0

var event_classes = {
	"movable": ["laser", "laser_circle", "laser_sweep"],
	"screen_effect": ["shake", "glitch","platform_colour", "camera_kick"]
}

var target_platform_colour = global.colours_raw["pink"]
var platform_colour_speed = 1
var showing_sun = false
var sun_mult = 0.0

var events = [
	{
		"type": "platform_colour",
		"beat": 1,
		"colour": "purple",
		"speed": 1
	},
	#{
		#"type": "shake",
		#"beat": 3,
		#"status": true,
		#"strength": 0.2
	#},
	{
		"type": "laser_sweep",
		"beat": 3,
		"pos": Vector2(5,1),
		"rot": 90,
		"amount": 8,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["green","green"]
	},
	{
		"type": "laser_sweep",
		"beat": 3.75,
		"pos": Vector2(3,1),
		"rot": 90,
		"amount": 8,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["green","green"]
	},
	{
		"type": "laser_sweep",
		"beat": 4.5,
		"pos": Vector2(5,1),
		"rot": 90,
		"amount": 8,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["green","green"]
	},
	{
		"type": "laser_sweep",
		"beat": 5.25,
		"pos": Vector2(5,1),
		"rot": 90,
		"amount": 8,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["green","green"]
	},
	{
		"type": "laser_sweep",
		"beat": 6,
		"pos": Vector2(5,1),
		"rot": 90,
		"amount": 8,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["green","green"]
	},
	{
		"type": "laser_sweep",
		"beat": 6,
		"pos": Vector2(7,1),
		"rot": 90,
		"amount": 8,
		"speed": 1.0/8.0,
		"distance": 300,
		"outwards": true,
		"colour": ["green","green"]
	},
	{
		"type": "platform_colour",
		"beat": 5,
		"colour": "hotpink",
		"speed": 1
	},
	{
		"type": "laser",
		"beat": 5,
		"pos": Vector2(2,5),
		"rot": 0,
		"colour": "blue"
	},
	{
		"type": "platform_colour",
		"beat": 7,
		"colour": "black",
		"speed": 10
	},
	{
		"type": "platform_colour",
		"beat": 10,
		"colour": "hotpink",
		"speed": 3
	},
	{
		"type": "laser_circle",
		"beat": 7,
		"pos": Vector2(5,3),
		"rot": 0,
		"radius": 500,
		"amount": 64,
		"edges": 12,
		"speed": 1.0/16.0,
		"colour": ["hotpink", "red"],
		"direction": 1
	},
	{
		"type": "visualizer",
		"beat": 7,
		"status": false,
	},
	{
		"type": "shake",
		"beat": 7,
		"status": false,
		"strength": 0.5
	},
	{
		"type": "vhs",
		"beat": 7,
		"status": true,
		"intensity": 1.0
	},
	{
		"type": "vhs",
		"beat": 10,
		"status": false,
		"intensity": 0.5
	},
	{
		"type": "laser_circle",
		"beat": 11,
		"pos": Vector2(2,3),
		"rot": 0,
		"radius": 400,
		"amount": 64,
		"edges": 7,
		"speed": 1.0/2.0,
		"colour": ["hotpink"],
		"direction": 1
	},
	{
		"type": "visualizer",
		"beat": 11,
		"status": true,
	},
	{
		"type": "camera_kick",
		"beat": 11,
		"status": true,
		"speed": 1.0/4.0
	},
	{
		"type": "laser_circle",
		"beat": 11.5,
		"pos": Vector2(8,3),
		"rot": 0,
		"radius": 400,
		"amount": 64,
		"edges": 7,
		"speed": 1.0/2.0,
		"colour": ["purple"],
		"direction": -1
	},
	
	{
		"type": "camera_kick",
		"beat": 43,
		"status": false,
		"speed": 1.0/4.0
	},
	{
		"type": "vhs",
		"beat": 23,
		"status": true,
		"intensity": 2.0
	},
	{
		"type": "vhs",
		"beat": 27,
		"status": false,
		"intensity": 0.3
	},
]

func _ready() -> void:
	bpm += epsilon
	$music.play(310.4)
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
					"laser_sweep":
						temp.speed = event.speed
						temp.amount = event.amount
						temp.distance = event.distance
						temp.outwards = event.outwards
						temp.colour = event.colour
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
