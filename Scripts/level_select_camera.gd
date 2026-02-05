extends Camera2D

#0.358

func _process(_delta: float) -> void:
	
	zoom.x = 0.6
	zoom.y = zoom.x
	
	position.x = get_global_mouse_position().x / 2
	position.y = (get_global_mouse_position().y / 2) - 500
