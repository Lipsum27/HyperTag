extends Control

var load_time = GlobalScript.timer
var cooldown_time = 2
var prev = cooldown_time+1

@onready var text = $PanelContainer/VBoxContainer/Number
@onready var sfx = $CountdownSFX

func _ready(): # setup
	GlobalScript.Song = 0
	load_time = GlobalScript.timer

func start_game():
	
	GlobalScript.timer = 0
	GlobalScript.last_tag_time = GlobalScript.timer
	
	if GlobalScript.player_count == 1: # Singleplayer vs Multiplayer obv
		GlobalScript.full_game_time = INF
		GlobalScript.current_tagger = 2
	else:
		GlobalScript.full_game_time = GlobalScript.round_time
		GlobalScript.current_tagger = randi_range(1, GlobalScript.player_count)
	
	get_tree().change_scene_to_file("res://Scenes/game.tscn")
	
	queue_free()

func _process(_delta: float) -> void: # main loop
	
	if GlobalScript.timer > (load_time + cooldown_time): # if the load time has passed since the scene was loaded
		start_game()
	
	text.set_text( str( int( round( 0.5 + ( load_time + cooldown_time - 1 ) - GlobalScript.timer ) + 1 ) ) )
	
	if round( 0.5 + ( load_time + cooldown_time - 1 ) - GlobalScript.timer ) + 1 < prev: # every second
		prev = round( 0.5 + ( load_time + cooldown_time - 1 ) - GlobalScript.timer ) + 1
		sfx.update_volume()
		sfx.play()
