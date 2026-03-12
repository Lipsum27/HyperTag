extends Control

const settingsScene = preload("res://Scenes/settings.tscn")
@onready var gameModeDescription = $"UI/VBoxContainer/Interface/Game Mode/ScrollContainer/GameModeDescription"
var typewriterTickLength = 3
var goalCharacters:int = 0

func _ready():
	if OS.has_feature("web"):
		get_node("UI/VBoxContainer/Interface/Main Interface/Quit").queue_free()
	globalScript.song = 1
	gameModeDescription.visible_characters = 0
	typewriter_effect()

func _process(_delta: float) -> void:
	get_node("UI").visible = !globalScript.settingsVisible
	get_node("UI/VBoxContainer/Interface/Game Mode/GameMode").text =  globalScript.gameModes[globalScript.currentGameMode]
	if gameModeDescription.visible_characters != goalCharacters:
		gameModeDescription.visible_characters += typewriterTickLength

func set_playerCount():
	if globalScript.playerInputs[1] == 0:
		globalScript.playerCount = 1
	elif globalScript.playerInputs[2] == 0:
		globalScript.playerCount = 2
	elif globalScript.playerInputs[3] == 0:
		globalScript.playerCount = 3
	else:
		globalScript.playerCount = 4

func _on_play_pressed() -> void:
	set_playerCount()
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_quit_pressed() -> void:
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	get_tree().quit()

func _on_settings_pressed() -> void:
	var settingsMenu = settingsScene.instantiate()
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	add_child(settingsMenu)

func _on_game_mode_pressed() -> void:
	if globalScript.currentGameMode != globalScript.gameModes.size() - 1:
		globalScript.currentGameMode += 1
	else:
		globalScript.currentGameMode = 0
	typewriter_effect()

func typewriter_effect():
	gameModeDescription.visible_characters = 0
	match globalScript.currentGameMode:
		0:
			gameModeDescription.set_text("-Flashing player is the tagger\n-Tag others\n-Avoid the tagger until the timer ends")
		1:
			gameModeDescription.set_text("-Flashing player is the runner\n-Escape other players until the timer ends\n-Winner gets double points")
		2:
			gameModeDescription.set_text("-Flashing player is the tagger\n-Tag others\n-Shorter timer\n-Timer resets on tag\n-Avoid the tagger until the timer ends")
	goalCharacters = gameModeDescription.text.length()
