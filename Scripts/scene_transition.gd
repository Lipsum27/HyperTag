extends Sprite2D

var animationProgress: float = 0.0
var targetProgress: float = 0.0
var transitionSpeed: float = 0.4

func _ready() -> void:
	material.set_shader_parameter("animationProgress", animationProgress)

func _process(delta: float) -> void:
	if GlobalScript.doSceneTransition:
		if GlobalScript.screenWipe:
			targetProgress = 1.0
		else:
			targetProgress = -0.15
		
		animationProgress += (( animationProgress - targetProgress ) / abs( animationProgress - targetProgress )) / -transitionSpeed * delta
		
		material.set_shader_parameter("animationProgress", animationProgress)
		
		if animationProgress >= 0.9:
			GlobalScript.screenWipe = false
			GlobalScript.sceneTransitionCompleted.emit()
		elif animationProgress <= 0:
			animationProgress = 0
	else:
		targetProgress = 0
		animationProgress = 0
		material.set_shader_parameter("animationProgress", 0)
		if GlobalScript.screenWipe:
			GlobalScript.screenWipe = false
			GlobalScript.sceneTransitionCompleted.emit()
