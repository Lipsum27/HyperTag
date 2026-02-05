extends Sprite2D
var counter = randf_range(0, 100)

func _process(_delta: float) -> void:
	counter += 1
	skew = 0.5 * (sin(counter/15.0))
	scale.y = 2 + 0.2 * (sin((counter/15.0)*2))
	visible = GlobalScript.slime
