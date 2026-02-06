extends Sprite2D

var animation_progress: float = 0.0
var target_progress: float = 0.0
var transition_speed: float = 25

func _ready() -> void:
	material.set_shader_parameter("animation_progress", animation_progress)

func _process(_delta: float) -> void:
	if GlobalScript.DoSceneTransition:
		if GlobalScript.ScreenWipe:
			target_progress = 1.0
		else:
			target_progress = -0.15
		
		animation_progress += (( animation_progress - target_progress ) / abs( animation_progress - target_progress )) / -transition_speed
		
		material.set_shader_parameter("animation_progress", animation_progress)
		
		if animation_progress >= 0.9:
			GlobalScript.ScreenWipe = false
			GlobalScript.scene_transition_completed.emit()
		elif animation_progress <= 0:
			animation_progress = 0
	else:
		target_progress = 0
		animation_progress = 0
		material.set_shader_parameter("animation_progress", 0)
		if GlobalScript.ScreenWipe:
			GlobalScript.ScreenWipe = false
			GlobalScript.scene_transition_completed.emit()
