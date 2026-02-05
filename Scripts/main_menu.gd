extends Control

const SettingsScene = preload("res://Scenes/settings.tscn")
@onready var MenuUI = $UI
@onready var GameMode = $"UI/VBoxContainer/Interface/Game Mode/GameMode"
@onready var GameModeDescription = $"UI/VBoxContainer/Interface/Game Mode/ScrollContainer/VBoxContainer/GameModeDescription"
@onready var Quit = $"UI/VBoxContainer/Interface/Main Interface/Quit"
var PrevState
var typewriter_break:bool
var typewriter_tick_length = 5
var typewriter_tick_time = 0

func _ready():
	if OS.has_feature("web"):
		Quit.queue_free()
	GlobalScript.Song = 1
	GameModeDescription.visible_characters = 0
	typewriter_effect()

func _process(_delta: float) -> void:
	MenuUI.visible = !GlobalScript.SettingsShown
	GameMode.text =  GlobalScript.game_modes[GlobalScript.current_game_mode]
	if typewriter_break == true:
		await get_tree().create_timer(typewriter_tick_time).timeout
		typewriter_break = false

func set_player_count():
	if GlobalScript.player_inputs[1] == 0:
		GlobalScript.player_count = 1
	elif GlobalScript.player_inputs[2] == 0:
		GlobalScript.player_count = 2
	elif GlobalScript.player_inputs[3] == 0:
		GlobalScript.player_count = 3
	else:
		GlobalScript.player_count = 4

func _on_play_pressed() -> void:
	set_player_count()
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().change_scene_to_file("res://Scenes/level_select.tscn")

func _on_quit_pressed() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	get_tree().quit()

func _on_settings_pressed() -> void:
	var SettingsMenu = SettingsScene.instantiate()
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	add_child(SettingsMenu)

func _on_game_mode_pressed() -> void:
	typewriter_break = true
	if GlobalScript.current_game_mode != GlobalScript.game_modes.size() - 1:
		GlobalScript.current_game_mode += 1
	else:
		GlobalScript.current_game_mode = 0
	typewriter_effect()

func typewriter_effect():
	while GameModeDescription.visible_characters > 0:
		if GameModeDescription.visible_characters > typewriter_tick_length:
			GameModeDescription.visible_characters -= typewriter_tick_length
		else:
			GameModeDescription.visible_characters = 0
		await get_tree().create_timer(typewriter_tick_time).timeout
	match GlobalScript.current_game_mode:
		0:
			GameModeDescription.set_text("-Flashing player is the tagger\n-Tag others\n-Avoid the tagger until the timer ends")
		1:
			GameModeDescription.set_text("-Flashing player is the runner\n-Escape other players until the timer ends\n-Winner gets double points")
		2:
			GameModeDescription.set_text("-Flashing player is the tagger\n-Tag others\n-Shorter timer\n-Timer resets on tag\n-Avoid the tagger until the timer ends")
	
	var total_length:int = GameModeDescription.text.length()

	@warning_ignore("integer_division")
	for i in range(1 + int(total_length/typewriter_tick_length)):
		if GameModeDescription.visible_characters+typewriter_tick_length > total_length:
			GameModeDescription.visible_characters = total_length
		else:
			GameModeDescription.visible_characters += typewriter_tick_length
		if typewriter_break:
			break
		await get_tree().create_timer(typewriter_tick_time).timeout
