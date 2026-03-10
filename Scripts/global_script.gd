extends Node

# Audio
const ChaozAirflow = preload("res://Assets/Audio/ParagonX9 - Chaoz Airflow [KIqJo_Iqhxs].mp3")
const HyperioxX = preload("res://Assets/Audio/ParagonX9 - HyperioxX [3pO9ueOMHJI].mp3")
var song = 1
var musicLibrary:Array = [
	null,
	ChaozAirflow,
	HyperioxX
]

# Signals
@warning_ignore("unused_signal")
signal sceneTransitionCompleted
#await globalScript.sceneTransitionCompleted

# Variables
var shakeDuration = 0
var shakeIntensity = 0
var playerCount:int = 1
var currentTagger
var timer: float = 0
var fullGameTime = 60
var roundTime:float
var lastTagTime = 0
var tagCooldown = 0.5
var rain:bool = true
var volume:float = linear_to_db(0.25)
var settingsVisible:bool = false
var slime:bool = false
var currentGameMode:int = 0
var level:int = 1
var screenShake:bool = true
var seekerSpeedUp:bool = true
var backgroundMovement:bool = true
var powerUpToggle = true
var powerUpCurrentlyLoaded = false
var debugHUD = false
var screenWipe = false
var doSceneTransition = true
var fpsCap = "Vsync"
var vSync = false
var tauntsEnabled = true
var fadeHud = false

# Arrays
var playerPos: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
]

var playerVel: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
]

var map1PlayerSpawns: Array[Vector2] = [
	Vector2(874, -336),
	Vector2(-874, -336),
	Vector2(230.0, -48),
	Vector2(-230.0, -48)
]

var map2PlayerSpawns: Array[Vector2] = [
	Vector2(609, -465),
	Vector2(-799, -465),
	Vector2(503, -48),
	Vector2(-503, -48),
]

var map3PlayerSpawns: Array[Vector2] = [
	Vector2(874, -48),
	Vector2(-874, -48),
	Vector2(230, -48),
	Vector2(-230, -48)
]

var map4PlayerSpawns: Array[Vector2] = [
	Vector2(552, -562),
	Vector2(-552, -562),
	Vector2(230, -48),
	Vector2(-230, -48)
]

var fpsCapValues: Array = ["Vsync", "Off", 30, 60, 120, 240, 360]

var p1PowerUp:Array = [0, 0, 0, 0]

var p2PowerUp:Array = [0, 0, 0, 0]

var p3PowerUp:Array = [0, 0, 0, 0]

var p4PowerUp:Array = [0, 0, 0, 0]

var playerInputs: Array = [1, 2, 0, 0]

var playerScores: Array = [0, 0, 0, 0]

var gameModes: Array = [
	"Standard Tag",
	"Reverse Tag",
	"Hot Potato"
]

func _physics_process(_delta):
	timer += _delta
	
	if str(fpsCap) == "Vsync":
		if !vSync:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			vSync = true
	else:
		if vSync:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			vSync = false
		if str(fpsCap) == "Off":
			Engine.max_fps = 0
		else:
			Engine.max_fps = fpsCap
	
	if currentGameMode == 0:
		roundTime = 60
	elif currentGameMode == 1:
		roundTime = 60
	elif currentGameMode == 2:
		roundTime = 20 #12.5
	
	for i in p1PowerUp.size():
		if p1PowerUp[i]> 0:
			p1PowerUp[i] -= _delta
		else:
			p1PowerUp[i] = 0
	for i in p2PowerUp.size():
		if p2PowerUp[i]> 0:
			p2PowerUp[i] -= _delta
		else:
			p2PowerUp[i] = 0
	for i in p3PowerUp.size():
		if p3PowerUp[i]> 0:
			p3PowerUp[i] -= _delta
		else:
			p3PowerUp[i] = 0
	for i in p4PowerUp.size():
		if p4PowerUp[i]> 0:
			p4PowerUp[i] -= _delta
		else:
			p4PowerUp[i] = 0
