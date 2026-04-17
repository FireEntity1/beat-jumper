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

var map = {"artist":"fireentity","audiofilename":"song.ogg","bpm":150.0,"data":[{"beat":0.0,"intensity":0.6,"status":true,"type":"vhs"},{"beat":0.0,"colour":"black","speed":100.0,"type":"platform_colour"},{"beat":0.0,"rot":0.0,"speed":7.0,"type":"cam_zoom","zoom":1.18},{"bar":false,"beat":0.0,"line":false,"smooth_line":false,"status":false,"type":"visualizer"},{"beat":0.5,"intensity":0.25,"status":true,"type":"chromabb"},{"bar":true,"beat":3.0,"line":false,"smooth_line":true,"status":true,"type":"visualizer"},{"beat":3.0,"colour":"pink","speed":5.0,"type":"platform_colour"},{"amount":8,"beat":4.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"beat":4.0,"speed":1.0,"status":true,"type":"camera_kick"},{"amount":8,"beat":6.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":8.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":10.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":12.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":14.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":16.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"beat":16.0,"colour":"hotpink","pos":[4.0,3.0],"rot":25.0,"type":"laser"},{"amount":7,"beat":17.0,"colour":["blue","red"],"direction":1.0,"edges":7.0,"pos":[5.0,0.0],"radius":1.0,"rot":0.0,"speed":0.5,"type":"laser_circle"},{"amount":8,"beat":18.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":20.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":22.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":24.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":26.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":28.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":8,"beat":30.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"beat":32.0,"speed":0.5,"status":true,"type":"camera_kick"},{"amount":8,"beat":32.0,"colour":["red"],"direction":true,"distance":411.0,"outwards":false,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"amount":7,"beat":33.0,"colour":["blue","red"],"direction":1.0,"edges":7.0,"pos":[5.0,0.0],"radius":1.0,"rot":0.0,"speed":0.5,"type":"laser_circle"},{"beat":34.0,"speed":0.25,"status":true,"type":"camera_kick"},{"amount":8,"beat":34.0,"colour":["hotpink"],"direction":false,"distance":411.0,"outwards":false,"pos":[8.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"beat":36.0,"speed":0.25,"status":false,"type":"camera_kick"},{"beat":36.0,"colour":"black","speed":15.0,"type":"platform_colour"},{"beat":36.0,"intensity":0.5,"status":false,"type":"vhs"},{"beat":36.5,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":37.0,"colour":"blue","speed":15.0,"type":"platform_colour"},{"beat":37.0,"speed":1.0,"status":true,"type":"camera_kick"},{"beat":37.0,"intensity":0.45,"status":true,"type":"chromabb"},{"amount":16,"beat":37.0,"colour":["blue"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"bar":true,"beat":37.0,"line":false,"smooth_line":true,"status":true,"type":"visualizer"},{"amount":16,"beat":38.0,"colour":["green"],"direction":true,"distance":81.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":39.0,"colour":["red"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":40.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":511.0,"rot":0.0,"speed":0.03125,"type":"laser_circle"},{"beat":40.0,"colour":"red","speed":5.0,"type":"platform_colour"},{"beat":40.0,"intensity":0.1,"status":true,"type":"chromabb"},{"beat":40.0,"rot":-3.0,"speed":1.0,"type":"cam_zoom","zoom":1.18},{"amount":16,"beat":41.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":471.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":41.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[3.0,3.0],"radius":401.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":42.0,"rot":3.0,"speed":1.0,"type":"cam_zoom","zoom":1.34},{"amount":16,"beat":42.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":351.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":42.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[3.0,3.0],"radius":731.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":43.0,"colour":"red","length":0.5,"pos":[5.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":43.5,"colour":"red","length":0.5,"pos":[7.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":44.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":44.0,"colour":"purple","pos":[1.0,5.0],"rot":0.0,"type":"laser"},{"beat":44.5,"intensity":0.45,"status":true,"type":"chromabb"},{"beat":44.5,"colour":"blue","speed":5.0,"type":"platform_colour"},{"amount":16,"beat":45.0,"colour":["blue"],"direction":false,"distance":81.0,"outwards":false,"pos":[5.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":46.0,"colour":["green"],"direction":true,"distance":81.0,"outwards":false,"pos":[5.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":47.0,"colour":["red"],"direction":false,"distance":81.0,"outwards":false,"pos":[5.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"beat":48.0,"rot":-3.0,"speed":1.0,"type":"cam_zoom","zoom":1.18},{"amount":16,"beat":48.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[7.0,3.0],"radius":511.0,"rot":0.0,"speed":0.03125,"type":"laser_circle"},{"beat":48.0,"colour":"red","speed":5.0,"type":"platform_colour"},{"beat":48.0,"intensity":0.1,"status":true,"type":"chromabb"},{"amount":16,"beat":49.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[7.0,3.0],"radius":471.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":49.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[7.0,3.0],"radius":401.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":50.0,"rot":3.0,"speed":1.0,"type":"cam_zoom","zoom":1.34},{"amount":16,"beat":50.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[7.0,3.0],"radius":351.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":50.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[7.0,3.0],"radius":731.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":51.0,"colour":"red","length":0.5,"pos":[2.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":51.5,"colour":"red","length":0.5,"pos":[9.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":52.0,"colour":"purple","pos":[1.0,5.0],"rot":0.0,"type":"laser"},{"beat":52.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":52.5,"intensity":0.45,"status":true,"type":"chromabb"},{"amount":16,"beat":53.0,"colour":["blue"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"beat":53.0,"intensity":0.45,"status":true,"type":"chromabb"},{"beat":53.0,"colour":"blue","speed":15.0,"type":"platform_colour"},{"amount":16,"beat":54.0,"colour":["green"],"direction":true,"distance":81.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":55.0,"colour":["red"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":56.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":511.0,"rot":0.0,"speed":0.03125,"type":"laser_circle"},{"beat":56.0,"rot":-3.0,"speed":1.0,"type":"cam_zoom","zoom":1.18},{"beat":56.0,"intensity":0.1,"status":true,"type":"chromabb"},{"beat":56.0,"colour":"red","speed":5.0,"type":"platform_colour"},{"amount":16,"beat":57.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":471.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":57.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[3.0,3.0],"radius":401.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":58.0,"rot":3.0,"speed":1.0,"type":"cam_zoom","zoom":1.34},{"amount":16,"beat":58.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":351.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":59.0,"colour":"red","length":0.5,"pos":[4.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":59.5,"colour":"red","length":0.5,"pos":[7.0,1.0],"rot":0.0,"type":"laser_slam"},{"amount":12,"beat":60.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":60.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"amount":4,"beat":60.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"beat":61.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.2},{"amount":12,"beat":61.0,"colour":["orange"],"direction":1.0,"edges":10.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":10,"beat":61.5,"colour":["blue"],"direction":true,"distance":31.0,"outwards":false,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":10,"beat":61.5,"colour":["blue"],"direction":false,"distance":31.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"beat":62.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"amount":16,"beat":62.0,"colour":["blue"],"direction":1.0,"edges":16.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":4,"beat":62.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":63.0,"colour":["green"],"direction":1.0,"edges":7.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":63.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.2},{"amount":10,"beat":63.5,"colour":["blue"],"direction":true,"distance":31.0,"outwards":false,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":10,"beat":63.5,"colour":["blue"],"direction":false,"distance":31.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":64.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":64.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"amount":4,"beat":64.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":65.0,"colour":["orange"],"direction":1.0,"edges":10.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":65.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.2},{"amount":10,"beat":65.5,"colour":["blue"],"direction":false,"distance":31.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":10,"beat":65.5,"colour":["blue"],"direction":true,"distance":31.0,"outwards":false,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":16,"beat":66.0,"colour":["blue"],"direction":1.0,"edges":16.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":66.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"amount":4,"beat":66.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":67.0,"colour":["green"],"direction":1.0,"edges":7.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"bar":true,"beat":67.0,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"beat":67.0,"speed":0.25,"status":true,"type":"camera_kick"},{"bar":true,"beat":67.125,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"amount":12,"beat":67.25,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"bar":true,"beat":67.25,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"bar":true,"beat":67.375,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"bar":true,"beat":67.5,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"amount":16,"beat":67.5,"colour":["blue"],"direction":1.0,"edges":16.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"bar":true,"beat":67.625,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"amount":12,"beat":67.75,"colour":["orange"],"direction":1.0,"edges":10.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"bar":true,"beat":67.75,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"bar":true,"beat":67.875,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"beat":68.0,"speed":1.0,"status":true,"type":"camera_kick"},{"amount":12,"beat":68.0,"colour":["purple"],"direction":true,"distance":300.0,"outwards":true,"pos":[4.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"bar":true,"beat":68.25,"line":false,"smooth_line":true,"status":true,"type":"visualizer"},{"beat":69.0,"intensity":0.45,"status":true,"type":"chromabb"},{"beat":69.0,"colour":"blue","speed":5.0,"type":"platform_colour"},{"amount":16,"beat":69.0,"colour":["blue"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":70.0,"colour":["green"],"direction":true,"distance":81.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":71.0,"colour":["red"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"beat":72.0,"rot":-3.0,"speed":1.0,"type":"cam_zoom","zoom":1.18},{"beat":72.0,"intensity":0.1,"status":true,"type":"chromabb"},{"beat":72.0,"colour":"red","speed":5.0,"type":"platform_colour"},{"amount":16,"beat":72.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":511.0,"rot":0.0,"speed":0.03125,"type":"laser_circle"},{"amount":16,"beat":73.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":471.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":73.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[3.0,3.0],"radius":401.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":74.0,"rot":3.0,"speed":1.0,"type":"cam_zoom","zoom":1.34},{"amount":16,"beat":74.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":351.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":74.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[3.0,3.0],"radius":731.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":75.0,"colour":"red","length":0.5,"pos":[5.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":75.5,"colour":"red","length":0.5,"pos":[7.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":76.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":76.0,"colour":"purple","pos":[1.0,5.0],"rot":0.0,"type":"laser"},{"beat":76.5,"intensity":0.45,"status":true,"type":"chromabb"},{"beat":77.0,"colour":"blue","speed":5.0,"type":"platform_colour"},{"amount":16,"beat":77.0,"colour":["blue"],"direction":false,"distance":81.0,"outwards":false,"pos":[5.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":78.0,"colour":["green"],"direction":true,"distance":81.0,"outwards":false,"pos":[5.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":79.0,"colour":["red"],"direction":false,"distance":81.0,"outwards":false,"pos":[5.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"beat":80.0,"rot":-3.0,"speed":1.0,"type":"cam_zoom","zoom":1.18},{"beat":80.0,"intensity":0.1,"status":true,"type":"chromabb"},{"beat":80.0,"colour":"red","speed":5.0,"type":"platform_colour"},{"amount":16,"beat":80.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[7.0,3.0],"radius":511.0,"rot":0.0,"speed":0.03125,"type":"laser_circle"},{"amount":16,"beat":81.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[7.0,3.0],"radius":471.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":81.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[7.0,3.0],"radius":401.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":82.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[7.0,3.0],"radius":351.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":82.0,"rot":3.0,"speed":1.0,"type":"cam_zoom","zoom":1.34},{"amount":16,"beat":82.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[7.0,3.0],"radius":731.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":83.0,"colour":"red","length":0.5,"pos":[2.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":83.5,"colour":"red","length":0.5,"pos":[9.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":84.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"beat":84.0,"colour":"purple","pos":[1.0,5.0],"rot":0.0,"type":"laser"},{"beat":84.5,"intensity":0.45,"status":true,"type":"chromabb"},{"beat":85.0,"intensity":0.45,"status":true,"type":"chromabb"},{"beat":85.0,"colour":"blue","speed":15.0,"type":"platform_colour"},{"amount":16,"beat":85.0,"colour":["blue"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":86.0,"colour":["green"],"direction":true,"distance":81.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":16,"beat":87.0,"colour":["red"],"direction":false,"distance":81.0,"outwards":false,"pos":[4.0,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"beat":88.0,"intensity":0.1,"status":true,"type":"chromabb"},{"beat":88.0,"colour":"red","speed":5.0,"type":"platform_colour"},{"amount":16,"beat":88.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":511.0,"rot":0.0,"speed":0.03125,"type":"laser_circle"},{"beat":88.0,"rot":-3.0,"speed":1.0,"type":"cam_zoom","zoom":1.18},{"amount":16,"beat":89.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":471.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"amount":16,"beat":89.5,"colour":["red"],"direction":1.0,"edges":11.0,"pos":[3.0,3.0],"radius":401.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":90.0,"rot":3.0,"speed":1.0,"type":"cam_zoom","zoom":1.34},{"amount":16,"beat":90.0,"colour":["purple"],"direction":1.0,"edges":12.0,"pos":[3.0,3.0],"radius":351.0,"rot":0.0,"speed":0.015625,"type":"laser_circle"},{"beat":91.0,"colour":"red","length":0.5,"pos":[4.0,1.0],"rot":0.0,"type":"laser_slam"},{"beat":91.5,"colour":"red","length":0.5,"pos":[7.0,1.0],"rot":0.0,"type":"laser_slam"},{"amount":12,"beat":92.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":92.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"amount":4,"beat":92.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"beat":93.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.2},{"amount":12,"beat":93.0,"colour":["orange"],"direction":1.0,"edges":10.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":10,"beat":93.5,"colour":["blue"],"direction":false,"distance":31.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":10,"beat":93.5,"colour":["blue"],"direction":true,"distance":31.0,"outwards":false,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"beat":94.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"amount":16,"beat":94.0,"colour":["blue"],"direction":1.0,"edges":16.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":4,"beat":94.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":95.0,"colour":["green"],"direction":1.0,"edges":7.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":95.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.2},{"amount":10,"beat":95.5,"colour":["blue"],"direction":false,"distance":31.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":10,"beat":95.5,"colour":["blue"],"direction":true,"distance":31.0,"outwards":false,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"beat":96.0,"speed":0.5,"status":true,"type":"camera_kick"},{"amount":12,"beat":96.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":96.0,"rot":0.0,"speed":1.0,"type":"cam_zoom","zoom":1.0},{"amount":4,"beat":96.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[5.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":96.5,"colour":["green"],"direction":1.0,"edges":7.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":12,"beat":97.0,"colour":["orange"],"direction":1.0,"edges":10.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":10,"beat":97.5,"colour":["blue"],"direction":false,"distance":31.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":97.5,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":10,"beat":97.5,"colour":["blue"],"direction":false,"distance":31.0,"outwards":false,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":16,"beat":98.0,"colour":["blue"],"direction":1.0,"edges":16.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"beat":98.0,"speed":0.25,"status":true,"type":"camera_kick"},{"amount":12,"beat":98.5,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":4,"beat":98.5,"colour":["red"],"direction":true,"distance":71.0,"outwards":true,"pos":[4.5,1.0],"rot":90.0,"speed":0.015625,"type":"laser_sweep"},{"amount":12,"beat":99.0,"colour":["green"],"direction":1.0,"edges":7.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"bar":true,"beat":99.0,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"bar":true,"beat":99.0,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"bar":true,"beat":99.0,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"bar":true,"beat":99.0,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"amount":12,"beat":99.0,"colour":["red"],"direction":1.0,"edges":12.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"amount":16,"beat":99.5,"colour":["blue"],"direction":1.0,"edges":16.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"bar":true,"beat":99.5,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"amount":12,"beat":99.5,"colour":["orange"],"direction":1.0,"edges":10.0,"pos":[5.0,3.0],"radius":501.0,"rot":0.0,"speed":0.0,"type":"laser_circle"},{"bar":true,"beat":99.5,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"bar":true,"beat":99.5,"line":false,"smooth_line":false,"status":true,"type":"visualizer"},{"bar":true,"beat":99.5,"line":false,"smooth_line":true,"status":false,"type":"visualizer"},{"bar":true,"beat":100.0,"line":false,"smooth_line":true,"status":true,"type":"visualizer"},{"beat":100.0,"speed":1.0,"status":true,"type":"camera_kick"},{"amount":12,"beat":100.0,"colour":["purple"],"direction":true,"distance":300.0,"outwards":true,"pos":[4.5,1.0],"rot":90.0,"speed":0.0625,"type":"laser_sweep"},{"amount":12,"beat":101.0,"colour":["hotpink"],"direction":true,"distance":300.0,"outwards":true,"pos":[1.0,1.0],"rot":90.0,"speed":0.25,"type":"laser_sweep"},{"beat":101.0,"intensity":0.25,"status":true,"type":"vhs"}],"imagename":"image.png","name":"FRACTURED/ANOMALY","offset":0.04,"preview_start":0.0,"sub":"","version":1.0}

func _ready() -> void:
	map.data = sanitize_json(map.data,true)
	bpm = float(map.bpm)
	bpm_changes = get_bpm_changes()
	if not is_preview:
		await get_tree().create_timer(1.0).timeout
		fade = false
		await get_tree().create_timer(2.0).timeout
		$music.play(0)
		await get_tree().create_timer(map.offset).timeout
		beat_running = true
	map.data.sort_custom(sort_by_trigger_beat)
	$main_platform/platform_sprite.modulate = global.colours_raw["purple"]
	global.bpm = bpm
	global.apply_prefire()

func _process(delta: float) -> void:
	global.bpm = bpm
	if fade:
		$fade/fade.modulate.a = lerpf($fade/fade.modulate.a,1.0,delta)
	else:
		$fade/fade.modulate.a = lerpf($fade/fade.modulate.a,0.0,delta)
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
						print("BREAK at idx:", event_index, " trigger:", trigger_beat, " beat:", beat, " event:", event.type, " event_beat:", event.beat)
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
