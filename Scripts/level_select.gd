extends Node2D

func _on_next_lvl_pressed() -> void:
	if GlobalScript.level == 4:
		GlobalScript.level = 1
	else:
		GlobalScript.level += 1

func _on_continue_pressed() -> void:
	GlobalScript.screenWipe = true
	await GlobalScript.sceneTransitionCompleted
	start_game()

func _on_button_pressed() -> void:
	GlobalScript.screenWipe = true
	await GlobalScript.sceneTransitionCompleted
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func start_game():
	GlobalScript.timer = 0
	GlobalScript.lastTagTime = GlobalScript.timer
	
	if GlobalScript.playerCount == 1: # Singleplayer vs Multiplayer obv
		GlobalScript.fullGameTime = INF
		GlobalScript.currentTagger = 2
	else:
		GlobalScript.fullGameTime = GlobalScript.roundTime
		GlobalScript.currentTagger = randi_range(1, GlobalScript.playerCount)
	
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
