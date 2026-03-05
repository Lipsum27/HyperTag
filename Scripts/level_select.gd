extends Node2D

@onready var camera = $"Camera2D"
@onready var levels = $"Levels"
const baseCameraZoom = 0.6
var goalOpacity = 1
var opacityBuffer = 0.1
var lerpSpeed = 0.1
var shittyCrashFix = false

func _ready() -> void:
	camera.zoom.x = baseCameraZoom
	camera.zoom.y = camera.zoom.x

func _process(_delta: float) -> void:
	camera.zoom.y = camera.zoom.x
	camera.position.x = get_global_mouse_position().x / 2
	camera.position.y = (get_global_mouse_position().y / 2) - 500
	levels.modulate.a = lerp(float(levels.modulate.a), float(goalOpacity), lerpSpeed)
	if levels.modulate.a - opacityBuffer < 0:
		goalOpacity = 1
		if globalScript.level == 4:
			globalScript.level = 1
		else:
			globalScript.level += 1

func _on_next_lvl_pressed() -> void:
	goalOpacity = 0

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
