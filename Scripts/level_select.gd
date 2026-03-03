extends Node2D

@onready var camera = $"Camera2D"
@onready var screenBlocker = $"CanvasLayer/blocker"
const baseCameraZoom = 0.6
var goalOffset = 0
var lerpSpeed = 0.3
const fullOffset = 1800

func _ready() -> void:
	camera.zoom.x = baseCameraZoom
	camera.zoom.y = camera.zoom.x
	screenBlocker.visible = false

func _process(_delta: float) -> void:
	camera.offset.y = lerp(camera.offset.y, float(goalOffset), lerpSpeed)
	camera.zoom.y = camera.zoom.x
	camera.position.x = get_global_mouse_position().x / 2
	camera.position.y = (get_global_mouse_position().y / 2) - 500
	
	if goalOffset != 0 && round(camera.offset.y) > goalOffset-10:
		#screenBlocker.visible = true
		#camera.offset.y = -goalOffset
		#screenBlocker.visible = false
		if globalScript.level == 4:
			globalScript.level = 1
		else:
			globalScript.level += 1
		goalOffset = 0

func _on_next_lvl_pressed() -> void:
	goalOffset = fullOffset

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
