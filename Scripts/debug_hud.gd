extends Control

func _process(_delta: float) -> void:
	if globalScript.debugHUD:
		get_node("CanvasLayer/FPS").set_text("FPS: " + str(Engine.get_frames_per_second()))
	else:
		get_node("CanvasLayer/FPS").set_text("")
