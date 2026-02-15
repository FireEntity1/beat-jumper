extends Node2D

var spectrum: AudioEffectSpectrumAnalyzerInstance
@onready var bars = []
const bar = preload("res://components/bar.tscn")
const count = 32
const max_freq = 10000.0
const min_freq = 20.0
const min_db = 50.0

var bars_visibility = 0.0

const rise_speed = 0.3
const fall_speed = 0.3
const normalization_speed = 0.0001

@export var smooth = false
@export var show_bars = true
@export var show_line = false

var line_values = []

var bar_energies = []
var max_energy = 0.1

var curve = Curve2D.new()

var fadein = 0.0

func _ready() -> void:
	for i in range(count):
		var temp = bar.instantiate()
		temp.position.x = i * 115
		add_child(temp)
	for child in get_children():
		if child is ColorRect:
			bars.append(child)
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	bar_energies.resize(count)
	for bar in bars:
			bar.scale.y = 0
	for i in range(count):
		bar_energies[i] = 0.0

func _process(delta: float) -> void:
	smooth = global.visualizer_smooth
	show_line = global.visualizer_line
	show_bars = global.visualizer_bar
	if fadein < 0.2:
		for bar in bars:
			bar.scale.y = 0
		fadein+=delta
	var prev_hz = min_freq
	var current_max = 0.0

	var target_visibility = 1.0 if show_bars else 0.0
	bars_visibility = lerp(bars_visibility, target_visibility, 20.0 * delta)

	for i in range(count):
		#var hz = min_freq * pow(max_freq / min_freq, float(i + 1) / count)
		var hz = lerp(min_freq, max_freq, float(i + 1) / count)
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		#var raw_energy = magnitude.length() * 100.0
		#if raw_energy > current_max:
			#current_max = raw_energy
		var magnitude_db = linear_to_db(magnitude.length())
		var energy = clamp((linear_to_db(magnitude.length()) + 60.0) / 60.0, 0.0, 1.0)
		
		if energy < 0.05:
			energy = 0.0
		if energy > bar_energies[i]:
			bar_energies[i] = lerp(bar_energies[i], energy, rise_speed*delta*60)
		else:
			bar_energies[i] = lerp(bar_energies[i], energy, fall_speed*delta*60)
		var current_bar = bars[i]
		var target_height = bar_energies[i] * 50 * clamp(0.2*max(i,1),0.5,3)
		if global.visualizer and show_bars:
			current_bar.scale.y = lerp(current_bar.scale.y, target_height/50*bars_visibility, 20.0*delta)
			#current_bar.scale.y = target_height/50
			current_bar.modulate = global.current_col*(2.0/3.0) * (1.0 + bar_energies[i] * 1.0)
			$line.modulate = global.current_col*(2.0/3.0) * (1.0 + bar_energies[i] * 1.0) * 2
		elif not show_bars and show_line:
			current_bar.scale.y = lerp(current_bar.scale.y, 0.0, 0.2)
		else:
			global.current_col*(2.0/3.0) * (1.0 + bar_energies[i] * 1.0)
			current_bar.scale.y = lerp(current_bar.scale.y, 0.0, 0.2)
		if i >= count:
			current_bar.scale.y = 0
		prev_hz = hz
		if current_max > max_energy:
			max_energy = lerp(max_energy, current_max, 0.3)
		else:
			max_energy = lerp(max_energy, current_max, normalization_speed)
	$line.clear_points()
	$line.scale = Vector2.ONE
	curve.clear_points()
	curve.bake_interval = 10.0
	if show_line:
		$line.modulate.a = lerp($line.modulate.a,1.0,delta*2)
	else:
		$line.modulate.a = lerp($line.modulate.a,0.0,delta*2)
	for i in range(count):
		#var point = Vector2(i * 115, -bars[i].scale.y*900 + 120)
		var height = bar_energies[i] * 50 * clamp(0.1*max(i,1),0.5,3)
		var point = Vector2(i * 115, -height * 18 + 120)
		if smooth:
			curve.add_point(point)
		else:
			$line.add_point(point)
	curve.add_point(Vector2(3600,120))
	$line.add_point(Vector2(3600,120))
	if smooth:
		for i in range(curve.point_count):
			var p_prev = curve.get_point_position(max(i - 1, 0))
			var p_next = curve.get_point_position(min(i + 1, curve.point_count - 1))
			
			var tangent = (p_next - p_prev) * 0.2
			
			if i == 0:
				tangent.y = 0
			
			curve.set_point_in(i, -tangent)
			curve.set_point_out(i, tangent)
		
		var points = []
		for point in curve.get_baked_points():
			point.y = min(point.y, 120)
			points.append(point)
		$line.points = points
