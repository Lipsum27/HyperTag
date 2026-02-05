extends Node2D

func _on_next_lvl_pressed() -> void:
	if GlobalScript.Level == 3:
		GlobalScript.Level = 1
	else:
		GlobalScript.Level += 1

func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/countdown.tscn")

func _on_button_pressed() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
