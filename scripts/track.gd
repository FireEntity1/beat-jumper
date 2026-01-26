extends ColorRect

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func change_name(name: String):
	$track_name.text = name
