extends Node2D

func _on_next_lvl_pressed() -> void:
	if globalScript.level == 4:
		globalScript.level = 1
	else:
		globalScript.level += 1

func _on_continue_pressed() -> void:
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	start_game()

func _on_button_pressed() -> void:
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func start_game():
	globalScript.timer = 0
	globalScript.lastTagTime = globalScript.timer
	
	if globalScript.playerCount == 1: # Singleplayer vs Multiplayer obv
		globalScript.fullGameTime = INF
		globalScript.currentTagger = 2
	else:
		globalScript.fullGameTime = globalScript.roundTime
		globalScript.currentTagger = randi_range(1, globalScript.playerCount)
	
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
