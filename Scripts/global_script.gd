extends Node

# Audio
const ChaozAirflow = preload("res://Assets/Audio/ParagonX9 - Chaoz Airflow [KIqJo_Iqhxs].mp3")
const HyperioxX = preload("res://Assets/Audio/ParagonX9 - HyperioxX [3pO9ueOMHJI].mp3")
var Song = 1
var Music_Library:Array = [
	null,
	ChaozAirflow,
	HyperioxX
]

# Signals
@warning_ignore("unused_signal")
signal scene_transition_completed
#GlobalScript.ScreenWipe = true
#await GlobalScript.scene_transition_completed
@warning_ignore("unused_signal")
signal scene_load_completed
#GlobalScript.scene_load_completed.emit()

# Variables
var shake_duration = 0
var shake_intensity = 0
var player_count:int = 1
var current_tagger
var timer: float = 0
var full_game_time = 60
var round_time:float
var last_tag_time = 0
var tag_cooldown = 2
var rain:bool = true
var volume:float = linear_to_db(0.25)
var SettingsShown:bool = false
var slime:bool = false
var current_game_mode:int = 0
var Level:int = 1
var screen_shake:bool = true
var seeker_speed_up:bool = true
var background_movement:bool = true
var PowerUpToggle = true
var PowerUpCurrentlyLoaded = false
var DebugHUD = false
var ScreenWipe = false
var DoSceneTransition = true

# Arrays
var player_pos: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
]

var player_vel: Array[Vector2] = [
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
	Vector2(0, 0),
]

var map_1_player_spawns: Array[Vector2] = [
	Vector2(874, -336),
	Vector2(-874, -336),
	Vector2(230.0, -48),
	Vector2(-230.0, -48)
]

var map_2_player_spawns: Array[Vector2] = [
	Vector2(609, -465),
	Vector2(-799, -465),
	Vector2(503, -48),
	Vector2(-503, -48),
]

var map_3_player_spawns: Array[Vector2] = [
	Vector2(874, -48),
	Vector2(-874, -48),
	Vector2(230, -48),
	Vector2(-230, -48)
]

var p1PowerUp:Array = [0, 0, 0, 0]

var p2PowerUp:Array = [0, 0, 0, 0]

var p3PowerUp:Array = [0, 0, 0, 0]

var p4PowerUp:Array = [0, 0, 0, 0]

var player_inputs: Array = [1, 0, 0, 0]

var player_scores: Array = [0, 0, 0, 0]

var game_modes: Array = [
	"Standard Tag",
	"Reverse Tag",
	"Hot Potato"
]

func _physics_process(_delta):
	timer += _delta
	
	if current_game_mode == 0:
		round_time = 60
	elif current_game_mode == 1:
		round_time = 60
	elif current_game_mode == 2:
		round_time = 20 #12.5
	
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
