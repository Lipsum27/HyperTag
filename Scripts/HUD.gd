extends CanvasLayer

@onready var mainHUD = $Control/HUD

const settingsScene = preload("res://Scenes/settings.tscn")
const powerUpSize = Vector2(144, 144)
const  lerpSpeed = 0.025

var scoresUpdated = false
var minSize = 25
var prevTime:int = 0
var sizeMult:float = 1
var maxScale = 0.5 # added to 1

var goalHudOpacity = 1
var hudOpacityLerpSpeed = 0.2

func _ready():
	globalScript.song = 2
	if OS.has_feature("web"):
		get_node("Control/Pause/VBoxContainer/Quit Game").queue_free()
		get_node("Control/GameOver/VBoxContainer/Quit Game").queue_free()

func update_scores(TimerEnded:bool):
	if TimerEnded:
		#region PostGame
		if globalScript.currentGameMode == 0: # regular
			if globalScript.currentTagger != 1:
				globalScript.playerScores[0] += 1
			if globalScript.currentTagger != 2 && globalScript.playerCount > 1:
				globalScript.playerScores[1] += 1
			if globalScript.currentTagger != 3 && globalScript.playerCount > 2:
				globalScript.playerScores[2] += 1
			if globalScript.currentTagger != 4 && globalScript.playerCount > 3:
				globalScript.playerScores[3] += 1
		elif globalScript.currentGameMode == 1: # reverse
			if globalScript.currentTagger == 1:
				globalScript.playerScores[0] += 2
			if globalScript.currentTagger == 2 && globalScript.playerCount > 1:
				globalScript.playerScores[1] += 2
			if globalScript.currentTagger == 3 && globalScript.playerCount > 2:
				globalScript.playerScores[2] += 2
			if globalScript.currentTagger == 4 && globalScript.playerCount > 3:
				globalScript.playerScores[3] += 2
		elif globalScript.currentGameMode == 2: # hot potato
			if globalScript.currentTagger != 1:
				globalScript.playerScores[0] += 1
			if globalScript.currentTagger != 2 && globalScript.playerCount > 1:
				globalScript.playerScores[1] += 1
			if globalScript.currentTagger != 3 && globalScript.playerCount > 2:
				globalScript.playerScores[2] += 1
			if globalScript.currentTagger != 4 && globalScript.playerCount > 3:
				globalScript.playerScores[3] += 1
		
		for i in 4:
			if i < globalScript.playerCount:
				get_node("Control/GameOver/VBoxContainer/Score_Update" + str(i+1)).set_text("P" + str(i+1) + ": " + str(globalScript.playerScores[i]))
			else:
				get_node("Control/GameOver/VBoxContainer/Score_Update" + str(i+1)).set_text("")
		scoresUpdated = true
	#endregion
	else:
		for i in 4:
			if globalScript.playerScores[i] != 0:
				get_node("Control/HUD/VBoxContainer/HBoxContainer/P" + str(i+1)).set_text(str(globalScript.playerScores[i]))
			else:
				get_node("Control/HUD/VBoxContainer/HBoxContainer/P" + str(i+1)).set_text("")

func _process(delta: float) -> void:
	
	mainHUD.modulate.a = lerp(float(mainHUD.modulate.a), float(goalHudOpacity), hudOpacityLerpSpeed)
	
	if globalScript.fadeHud:
		goalHudOpacity = 0.2
	else:
		goalHudOpacity = 1
	
	if prevTime != int(globalScript.timer):
		sizeMult = (1 + maxScale * (1 -(globalScript.fullGameTime - globalScript.timer) / globalScript.fullGameTime ))
		prevTime = int(globalScript.timer)
		
	sizeMult = lerp(sizeMult, 1.0, lerpSpeed)
	
	get_node("Control/HUD/VBoxContainer/Time").add_theme_font_size_override("font_size", 128 * sizeMult)
	
	if globalScript.timer > globalScript.fullGameTime: # Game Ends
		# After game ends
		if !scoresUpdated:
			update_scores(true)
		
		get_tree().paused = true # Paused
		get_node("Control/GameOver").visible = true # Show game over menu
		get_node("Control/Pause").visible = false # Garuntee pause is hidden
		mainHUD.visible = false
	else:
		# During game loop
		if globalScript.playerCount != 1: # Hide hud in singleplayer
			mainHUD.visible = true
		else:
			mainHUD.visible = false
		
		get_node("Control/GameOver").visible = false # Hide game over menu
		
		get_node("Control/Pause").visible = get_tree().paused and !globalScript.settingsVisible # Show menu when paused
		get_node("Control/HUD/VBoxContainer/Time").set_text(str(1 + int(globalScript.fullGameTime - globalScript.timer))) # Set timer label
		
		update_scores(false)
	
	if Input.is_action_just_pressed("Pause"): # Pause on esc / start
		if globalScript.timer < globalScript.fullGameTime:
			get_tree().paused = !get_tree().paused
	
	get_node("Control/Loading").visible = false
	
	for i in 4:
		#region P1
		var currentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player1/" + str(i))
		if globalScript.p1PowerUp[i] > 0:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, powerUpSize, 0.1 *delta*100)
		else:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, Vector2(0, 0), 0.1 *delta*100)
		if currentNode.custom_minimum_size.x < minSize && globalScript.p1PowerUp[i] <= 0:
			currentNode.custom_minimum_size = Vector2(0, 0)
			currentNode.visible = false
		else:
			currentNode.visible = true
#endregion
		
		#region P2
		currentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player2/" + str(i))
		if globalScript.p2PowerUp[i] > 0:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, powerUpSize, 0.1 *delta*100)
		else:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, Vector2(0, 0), 0.1 *delta*100)
		if currentNode.custom_minimum_size.x < minSize && globalScript.p2PowerUp[i] <= 0:
			currentNode.custom_minimum_size = Vector2(0, 0)
			currentNode.visible = false
		else:
			currentNode.visible = true
#endregion
		
		#region P3
		currentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player3/" + str(i))
		if globalScript.p3PowerUp[i] > 0:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, powerUpSize, 0.1 *delta*100)
		else:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, Vector2(0, 0), 0.1 *delta*100)
		if currentNode.custom_minimum_size.x < minSize && globalScript.p3PowerUp[i] <= 0:
			currentNode.custom_minimum_size = Vector2(0, 0)
			currentNode.visible = false
		else:
			currentNode.visible = true
#endregion
		
		#region P4
		currentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player4/" + str(i))
		if globalScript.p4PowerUp[i] > 0:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, powerUpSize, 0.1 *delta*100)
		else:
			currentNode.custom_minimum_size = lerp(currentNode.custom_minimum_size, Vector2(0, 0), 0.1 *delta*100)
		if currentNode.custom_minimum_size.x < minSize && globalScript.p4PowerUp[i] <= 0:
			currentNode.custom_minimum_size = Vector2(0, 0)
			currentNode.visible = false
		else:
			currentNode.visible = true
#endregion

#Buttons
func _on_resume_pressed_pause() -> void:
	get_tree().paused = false

func _on_quit_to_menu_pressed_pause() -> void:
	get_tree().paused = false
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_quit_to_menu_pressed_gameover() -> void:
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _on_quit_game_pressed_pause() -> void:
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	get_tree().quit()

func _on_quit_game_pressed_gameover() -> void:
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	get_tree().quit()

func set_playerCount():
	for i in range(4):
		if globalScript.playerInputs[i+1] == 0:
			globalScript.playerCount = i+1
			break

func _on_play_again_pressed() -> void:
	
	set_playerCount()
	
	globalScript.timer = 0
	globalScript.lastTagTime = globalScript.timer
	
	globalScript.fullGameTime = globalScript.roundTime
	globalScript.currentTagger = round(randf_range(1, globalScript.playerCount))
	
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	
	get_tree().paused = false
	
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	var settingsMenu = settingsScene.instantiate()
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	add_child(settingsMenu)
