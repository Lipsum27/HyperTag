extends Sprite2D

var animationProgress: float = 0.0
var targetProgress: float = 0.0
var transitionSpeed: float = 2.5

func _ready() -> void:
	material.set_shader_parameter("animation_progress", animationProgress)

func _process(delta: float) -> void:
	if GlobalScript.doSceneTransition:
		if GlobalScript.screenWipe:
			targetProgress = 1.0
		else:
			targetProgress = -0.15
		
		animationProgress = move_toward(animationProgress, targetProgress, transitionSpeed * delta)
		
		material.set_shader_parameter("animation_progress", animationProgress)
		
		if animationProgress >= 0.9:
			GlobalScript.screenWipe = false
			GlobalScript.sceneTransitionCompleted.emit()
		elif animationProgress <= 0:
			animationProgress = 0
	else:
		targetProgress = 0
		animationProgress = 0
		material.set_shader_parameter("animation_progress", 0)
		if GlobalScript.screenWipe:
			GlobalScript.screenWipe = false
			GlobalScript.sceneTransitionCompleted.emit()
