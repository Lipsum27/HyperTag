extends CanvasLayer

@onready var scoreLabel = $Control/GameOver/VBoxContainer/Score_Update
@onready var scoreLabel1 = $Control/GameOver/VBoxContainer/Score_Update1
@onready var scoreLabel2 = $Control/GameOver/VBoxContainer/Score_Update2
@onready var scoreLabel3 = $Control/GameOver/VBoxContainer/Score_Update3
@onready var scoreLabel4 = $Control/GameOver/VBoxContainer/Score_Update4
@onready var mainHUD = $Control/HUD
@onready var timerHUD = $Control/HUD/VBoxContainer/Time
@onready var scoreHUD1 = $Control/HUD/VBoxContainer/HBoxContainer/P1
@onready var scoreHUD2 = $Control/HUD/VBoxContainer/HBoxContainer/P2
@onready var scoreHUD3 = $Control/HUD/VBoxContainer/HBoxContainer/P3
@onready var scoreHUD4 = $Control/HUD/VBoxContainer/HBoxContainer/P4

const settingsScene = preload("res://Scenes/settings.tscn")
const powerUpSize = Vector2(144, 144)

var scoresUpdated = false
var minSize = 25

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
		scoreLabel1.set_text("")
		scoreLabel2.set_text("")
		scoreLabel3.set_text("")
		scoreLabel4.set_text("")
		if globalScript.playerCount == 2:
			scoreLabel1.set_text("P1: " + str(globalScript.playerScores[0]))
			scoreLabel2.set_text("P2: " + str(globalScript.playerScores[1]))
		if globalScript.playerCount == 3:
			scoreLabel1.set_text("P1: " + str(globalScript.playerScores[0]))
			scoreLabel2.set_text("P2: " + str(globalScript.playerScores[1]))
			scoreLabel3.set_text("P3: " + str(globalScript.playerScores[2]))
		if globalScript.playerCount == 4:
			scoreLabel1.set_text("P1: " + str(globalScript.playerScores[0]))
			scoreLabel2.set_text("P2: " + str(globalScript.playerScores[1]))
			scoreLabel3.set_text("P3: " + str(globalScript.playerScores[2]))
			scoreLabel4.set_text("P4: " + str(globalScript.playerScores[3]))
		scoresUpdated = true
	#endregion
	else:
		#region MidGame
		timerHUD.modulate.a = 0.5
		scoreHUD1.modulate.a = 0.5
		scoreHUD2.modulate.a = 0.5
		scoreHUD3.modulate.a = 0.5
		scoreHUD4.modulate.a = 0.5
		scoreHUD1.set_text("") # Wipe
		scoreHUD2.set_text("")
		scoreHUD3.set_text("")
		scoreHUD4.set_text("")
		if globalScript.playerScores[0] != 0:
			scoreHUD1.set_text(str(globalScript.playerScores[0])) # Set Label if not 0
		if globalScript.playerScores[1] != 0:
			scoreHUD2.set_text(str(globalScript.playerScores[1])) # Set Label if not 0
		if globalScript.playerScores[2] != 0:
			scoreHUD3.set_text(str(globalScript.playerScores[2])) # Set Label if not 0
		if globalScript.playerScores[3] != 0:
			scoreHUD4.set_text(str(globalScript.playerScores[3])) # Set Label if not 0
#endregion

func _process(delta: float) -> void:
	
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
		timerHUD.set_text(str(1 + int(globalScript.fullGameTime - globalScript.timer))) # Set timer label
		
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
	if globalScript.playerInputs[1] == 0:
		globalScript.playerCount = 1
	elif globalScript.playerInputs[2] == 0:
		globalScript.playerCount = 2
	elif globalScript.playerInputs[3] == 0:
		globalScript.playerCount = 3
	else:
		globalScript.playerCount = 4

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
