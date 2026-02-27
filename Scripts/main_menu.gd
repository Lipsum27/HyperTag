extends Control

const settingsScene = preload("res://Scenes/settings.tscn")
@onready var gameModeDescription = $"UI/VBoxContainer/Interface/Game Mode/ScrollContainer/GameModeDescription"
var typewriterBreak:bool
var typewriterTickLength = 10
var typewriterTickTime = 0.025

func _ready():
	if OS.has_feature("web"):
		get_node("UI/VBoxContainer/Interface/Main Interface/Quit").queue_free()
	GlobalScript.song = 1
	gameModeDescription.visible_characters = 0
	typewriter_effect()

func _process(_delta: float) -> void:
	get_node("UI").visible = !GlobalScript.settingsVisible
	get_node("UI/VBoxContainer/Interface/Game Mode/GameMode").text =  GlobalScript.gameModes[GlobalScript.currentGameMode]
	if typewriterBreak == true:
		await get_tree().create_timer(typewriterTickTime).timeout
		typewriterBreak = false

func set_playerCount():
	if GlobalScript.playerInputs[1] == 0:
		GlobalScript.playerCount = 1
	elif GlobalScript.playerInputs[2] == 0:
		GlobalScript.playerCount = 2
	elif GlobalScript.playerInputs[3] == 0:
		GlobalScript.playerCount = 3
	else:
		GlobalScript.playerCount = 4

func _on_play_pressed() -> void:
	set_playerCount()
	GlobalScript.screenWipe = true
	await GlobalScript.sceneTransitionCompleted
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_quit_pressed() -> void:
	GlobalScript.screenWipe = true
	await GlobalScript.sceneTransitionCompleted
	get_tree().quit()

func _on_settings_pressed() -> void:
	var settingsMenu = settingsScene.instantiate()
	GlobalScript.screenWipe = true
	await GlobalScript.sceneTransitionCompleted
	add_child(settingsMenu)

func _on_game_mode_pressed() -> void:
	typewriterBreak = true
	if GlobalScript.currentGameMode != GlobalScript.gameModes.size() - 1:
		GlobalScript.currentGameMode += 1
	else:
		GlobalScript.currentGameMode = 0
	typewriter_effect()

func typewriter_effect():
	while gameModeDescription.visible_characters > 0:
		if gameModeDescription.visible_characters > typewriterTickLength:
			gameModeDescription.visible_characters -= typewriterTickLength
		else:
			gameModeDescription.visible_characters = 0
		await get_tree().create_timer(typewriterTickTime).timeout
	match GlobalScript.currentGameMode:
		0:
			gameModeDescription.set_text("-Flashing player is the tagger\n-Tag others\n-Avoid the tagger until the timer ends")
		1:
			gameModeDescription.set_text("-Flashing player is the runner\n-Escape other players until the timer ends\n-Winner gets double points")
		2:
			gameModeDescription.set_text("-Flashing player is the tagger\n-Tag others\n-Shorter timer\n-Timer resets on tag\n-Avoid the tagger until the timer ends")
	
	var totalLength:int = gameModeDescription.text.length()

	@warning_ignore("integer_division")
	for i in range(1 + int(totalLength/typewriterTickLength)):
		if gameModeDescription.visible_characters+typewriterTickLength > totalLength:
			gameModeDescription.visible_characters = totalLength
		else:
			gameModeDescription.visible_characters += typewriterTickLength
		if typewriterBreak:
			break
		await get_tree().create_timer(typewriterTickTime).timeout
