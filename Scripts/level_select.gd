extends Node2D

func _on_next_lvl_pressed() -> void:
	if GlobalScript.Level == 3:
		GlobalScript.Level = 1
	else:
		GlobalScript.Level += 1

func _on_continue_pressed() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	start_game()

func _on_button_pressed() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func start_game():
	
	GlobalScript.timer = 0
	GlobalScript.last_tag_time = GlobalScript.timer
	
	if GlobalScript.player_count == 1: # Singleplayer vs Multiplayer obv
		GlobalScript.full_game_time = INF
		GlobalScript.current_tagger = 2
	else:
		GlobalScript.full_game_time = GlobalScript.round_time
		GlobalScript.current_tagger = randi_range(1, GlobalScript.player_count)
	
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
