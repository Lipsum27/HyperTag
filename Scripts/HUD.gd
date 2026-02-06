extends CanvasLayer

@onready var ScoreLabel = $Control/GameOver/VBoxContainer/Score_Update
@onready var ScoreLabel1 = $Control/GameOver/VBoxContainer/Score_Update1
@onready var ScoreLabel2 = $Control/GameOver/VBoxContainer/Score_Update2
@onready var ScoreLabel3 = $Control/GameOver/VBoxContainer/Score_Update3
@onready var ScoreLabel4 = $Control/GameOver/VBoxContainer/Score_Update4
@onready var MainHUD = $Control/HUD
@onready var TimerHUD = $Control/HUD/VBoxContainer/Time
@onready var ScoreHUD1 = $Control/HUD/VBoxContainer/HBoxContainer/P1
@onready var ScoreHUD2 = $Control/HUD/VBoxContainer/HBoxContainer/P2
@onready var ScoreHUD3 = $Control/HUD/VBoxContainer/HBoxContainer/P3
@onready var ScoreHUD4 = $Control/HUD/VBoxContainer/HBoxContainer/P4

const SettingsScene = preload("res://Scenes/settings.tscn")
const PowerUpSize = Vector2(144, 144)

var ScoresUpdated = false
var MinSize = 25

func _ready():
	GlobalScript.Song = 2
	if OS.has_feature("web"):
		get_node("Control/Pause/VBoxContainer/Quit Game").queue_free()
		get_node("Control/GameOver/VBoxContainer/Quit Game").queue_free()

func update_scores(TimerEnded:bool):
	if TimerEnded:
		#region PostGame
		if GlobalScript.current_game_mode == 0: # regular
			if GlobalScript.current_tagger != 1:
				GlobalScript.player_scores[0] += 1
			if GlobalScript.current_tagger != 2 && GlobalScript.player_count > 1:
				GlobalScript.player_scores[1] += 1
			if GlobalScript.current_tagger != 3 && GlobalScript.player_count > 2:
				GlobalScript.player_scores[2] += 1
			if GlobalScript.current_tagger != 4 && GlobalScript.player_count > 3:
				GlobalScript.player_scores[3] += 1
		elif GlobalScript.current_game_mode == 1: # reverse
			if GlobalScript.current_tagger == 1:
				GlobalScript.player_scores[0] += 2
			if GlobalScript.current_tagger == 2 && GlobalScript.player_count > 1:
				GlobalScript.player_scores[1] += 2
			if GlobalScript.current_tagger == 3 && GlobalScript.player_count > 2:
				GlobalScript.player_scores[2] += 2
			if GlobalScript.current_tagger == 4 && GlobalScript.player_count > 3:
				GlobalScript.player_scores[3] += 2
		elif GlobalScript.current_game_mode == 2: # hot potato
			if GlobalScript.current_tagger != 1:
				GlobalScript.player_scores[0] += 1
			if GlobalScript.current_tagger != 2 && GlobalScript.player_count > 1:
				GlobalScript.player_scores[1] += 1
			if GlobalScript.current_tagger != 3 && GlobalScript.player_count > 2:
				GlobalScript.player_scores[2] += 1
			if GlobalScript.current_tagger != 4 && GlobalScript.player_count > 3:
				GlobalScript.player_scores[3] += 1
		ScoreLabel1.set_text("")
		ScoreLabel2.set_text("")
		ScoreLabel3.set_text("")
		ScoreLabel4.set_text("")
		if GlobalScript.player_count == 2:
			ScoreLabel1.set_text("P1: " + str(GlobalScript.player_scores[0]))
			ScoreLabel2.set_text("P2: " + str(GlobalScript.player_scores[1]))
		if GlobalScript.player_count == 3:
			ScoreLabel1.set_text("P1: " + str(GlobalScript.player_scores[0]))
			ScoreLabel2.set_text("P2: " + str(GlobalScript.player_scores[1]))
			ScoreLabel3.set_text("P3: " + str(GlobalScript.player_scores[2]))
		if GlobalScript.player_count == 4:
			ScoreLabel1.set_text("P1: " + str(GlobalScript.player_scores[0]))
			ScoreLabel2.set_text("P2: " + str(GlobalScript.player_scores[1]))
			ScoreLabel3.set_text("P3: " + str(GlobalScript.player_scores[2]))
			ScoreLabel4.set_text("P4: " + str(GlobalScript.player_scores[3]))
		ScoresUpdated = true
	#endregion
	else:
		#region MidGame
		TimerHUD.modulate.a = 0.5
		ScoreHUD1.modulate.a = 0.5
		ScoreHUD2.modulate.a = 0.5
		ScoreHUD3.modulate.a = 0.5
		ScoreHUD4.modulate.a = 0.5
		ScoreHUD1.set_text("") # Wipe
		ScoreHUD2.set_text("")
		ScoreHUD3.set_text("")
		ScoreHUD4.set_text("")
		if GlobalScript.player_scores[0] != 0:
			ScoreHUD1.set_text(str(GlobalScript.player_scores[0])) # Set Label if not 0
		if GlobalScript.player_scores[1] != 0:
			ScoreHUD2.set_text(str(GlobalScript.player_scores[1])) # Set Label if not 0
		if GlobalScript.player_scores[2] != 0:
			ScoreHUD3.set_text(str(GlobalScript.player_scores[2])) # Set Label if not 0
		if GlobalScript.player_scores[3] != 0:
			ScoreHUD4.set_text(str(GlobalScript.player_scores[3])) # Set Label if not 0
#endregion

func _process(_delta: float) -> void:
	
	if GlobalScript.timer > GlobalScript.full_game_time: # Game Ends
		# After game ends
		if !ScoresUpdated:
			update_scores(true)
		
		get_tree().paused = true # Paused
		get_node("Control/GameOver").visible = true # Show game over menu
		get_node("Control/Pause").visible = false # Garuntee pause is hidden
		MainHUD.visible = false
	else:
		# During game loop
		if GlobalScript.player_count != 1: # Hide hud in singleplayer
			MainHUD.visible = true
		else:
			MainHUD.visible = false
		
		get_node("Control/GameOver").visible = false # Hide game over menu
		
		get_node("Control/Pause").visible = get_tree().paused and !GlobalScript.SettingsShown # Show menu when paused
		TimerHUD.set_text(str(1 + int(GlobalScript.full_game_time - GlobalScript.timer))) # Set timer label
		
		update_scores(false)
	
	if Input.is_action_just_pressed("Pause"): # Pause on esc / start
		if GlobalScript.timer < GlobalScript.full_game_time:
			get_tree().paused = !get_tree().paused
	
	get_node("Control/Loading").visible = false
	
	for i in 4:
		#region P1
		var CurrentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player1/" + str(i))
		if GlobalScript.p1PowerUp[i] > 0:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, PowerUpSize, 0.1)
		else:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, Vector2(0, 0), 0.1)
		if CurrentNode.custom_minimum_size.x < MinSize && GlobalScript.p1PowerUp[i] <= 0:
			CurrentNode.custom_minimum_size = Vector2(0, 0)
			CurrentNode.visible = false
		else:
			CurrentNode.visible = true
#endregion
		
		#region P2
		CurrentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player2/" + str(i))
		if GlobalScript.p2PowerUp[i] > 0:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, PowerUpSize, 0.1)
		else:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, Vector2(0, 0), 0.1)
		if CurrentNode.custom_minimum_size.x < MinSize && GlobalScript.p2PowerUp[i] <= 0:
			CurrentNode.custom_minimum_size = Vector2(0, 0)
			CurrentNode.visible = false
		else:
			CurrentNode.visible = true
#endregion
		
		#region P3
		CurrentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player3/" + str(i))
		if GlobalScript.p3PowerUp[i] > 0:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, PowerUpSize, 0.1)
		else:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, Vector2(0, 0), 0.1)
		if CurrentNode.custom_minimum_size.x < MinSize && GlobalScript.p3PowerUp[i] <= 0:
			CurrentNode.custom_minimum_size = Vector2(0, 0)
			CurrentNode.visible = false
		else:
			CurrentNode.visible = true
#endregion
		
		#region P4
		CurrentNode = get_node("Control/PowerUp/VBoxContainer/HBoxContainer/Player4/" + str(i))
		if GlobalScript.p4PowerUp[i] > 0:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, PowerUpSize, 0.1)
		else:
			CurrentNode.custom_minimum_size = lerp(CurrentNode.custom_minimum_size, Vector2(0, 0), 0.1)
		if CurrentNode.custom_minimum_size.x < MinSize && GlobalScript.p4PowerUp[i] <= 0:
			CurrentNode.custom_minimum_size = Vector2(0, 0)
			CurrentNode.visible = false
		else:
			CurrentNode.visible = true
#endregion

#Buttons
func _on_resume_pressed_pause() -> void:
	get_tree().paused = false

func _on_quit_to_menu_pressed_pause() -> void:
	get_tree().paused = false
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_quit_to_menu_pressed_gameover() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
func _on_quit_game_pressed_pause() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().quit()

func _on_quit_game_pressed_gameover() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().quit()

func set_player_count():
	if GlobalScript.player_inputs[1] == 0:
		GlobalScript.player_count = 1
	elif GlobalScript.player_inputs[2] == 0:
		GlobalScript.player_count = 2
	elif GlobalScript.player_inputs[3] == 0:
		GlobalScript.player_count = 3
	else:
		GlobalScript.player_count = 4

func _on_play_again_pressed() -> void:
	
	set_player_count()
	
	GlobalScript.timer = 0
	GlobalScript.last_tag_time = GlobalScript.timer
	
	GlobalScript.full_game_time = GlobalScript.round_time
	GlobalScript.current_tagger = round(randf_range(1, GlobalScript.player_count))
	
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	
	get_tree().paused = false
	
	get_tree().reload_current_scene()

func _on_settings_pressed() -> void:
	var SettingsMenu = SettingsScene.instantiate()
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	add_child(SettingsMenu)
	SettingsMenu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
