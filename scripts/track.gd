extends ColorRect

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func change_name(name: String):
	$track_name.text = name

func update_length(scale):
	for child in $hbox.get_children():
		child.update_length(scale)
