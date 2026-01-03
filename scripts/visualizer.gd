extends Node2D

var spectrum: AudioEffectSpectrumAnalyzerInstance
@onready var bars = get_children()
const bar = preload("res://components/bar.tscn")
const count = 32
const max_freq = 8000.0
const min_freq = 20.0
const min_db = 50.0

const rise_speed = 3
const fall_speed = 0.1
const normalization_speed = 0.02

var bar_energies = []
var max_energy = 0.1

func _ready() -> void:
	for i in range(count):
		var temp = bar.instantiate()
		temp.position.x = i * 115
		add_child(temp)
	bars = get_children()
	spectrum = AudioServer.get_bus_effect_instance(0, 0)
	bar_energies.resize(count)
	for i in range(count):
		bar_energies[i] = 0.0

func _process(delta: float) -> void:
	var prev_hz = 0.0
	var current_max = 0.0
	for i in range(count):
		var hz = lerp(min_freq, max_freq, float(i + 1) / count)
		#var hz = ((max_freq-min_freq)/count)*(i)
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz)
		var raw_energy = magnitude.length() * 100.0
		if raw_energy > current_max:
			current_max = raw_energy
		var energy = clamp(raw_energy / max(max_energy, 0.1), 0.0, 1.0)
		if energy > bar_energies[i]:
			bar_energies[i] = lerp(bar_energies[i], energy, rise_speed)
		else:
			bar_energies[i] = lerp(bar_energies[i], energy, fall_speed)
		var current_bar = bars[i]
		var target_height = bar_energies[i] * 200 * clamp(1/max(i,1),0.3,10)
		
		current_bar.scale.y = lerp(current_bar.scale.y, target_height/50, 0.5)
		current_bar.modulate = Color(1.5, 0.5, 2.0) * (1.0 + bar_energies[i] * 1.0)
		if i >= count:
			current_bar.scale.y = 0
		prev_hz = hz
		if current_max > max_energy:
			max_energy = lerp(max_energy, current_max, 0.3)
		else:
			max_energy = lerp(max_energy, current_max, normalization_speed)
	bars[32].scale.y = 0
