extends Node2D

@onready var gradient = $Tilemaps/BG_Grad
@onready var buildings = $Tilemaps/Buildings
@onready var lamp_posts = $Tilemaps/LampPost
@onready var light1 = $"Tilemaps/LampPost/Lights/1"
@onready var light2 = $"Tilemaps/LampPost/Lights/2"
@onready var light3 = $"Tilemaps/LampPost/Lights/3"
@onready var light4 = $"Tilemaps/LampPost/Lights/4"
@onready var light5 = $"Tilemaps/LampPost/Lights/5"
@onready var light6 = $"Tilemaps/LampPost/Lights/6"
@onready var light7 = $"Tilemaps/LampPost/Lights/7"
@onready var rain = $Rain

# Variables
@export var Layer = 0
const gradient_offset = 500
const tilemap_offset = 850
const light_offset = 850
var time = 0
var lights: Array
var light_pos: Array[Vector2] = [
	Vector2(-1878.0, -41.5),
	Vector2(-1512.0, 86.875),
	Vector2(-743.0, -233.25),
	Vector2(-470.0, -233.125),
	Vector2(216.0, 86.75),
	Vector2(1002.0, -105.25),
	Vector2(2026.0, -41.35),
]
var sin_values: Array = []

func _ready():
	randomize()
	for i in range(6):
		sin_values.append(randf_range(0.005, 0.02))

	for i in range(6):
		sin_values.append(randf_range(-20, -5))

func _process(_delta: float) -> void:
	lights = [light1, light2, light3, light4, light5, light6, light7]
	rain.visible = GlobalScript.rain # rain toggle
	time += randf_range(0.5, 2)
	move()

func move(): # Set offsets
	var gradient_y_offset = -350
	var generic_y_offset = -500
	
	if get_tree().current_scene.name == "MainMenu" or get_tree().current_scene.name == "Countdown" or get_tree().current_scene.name == "background" or get_tree().current_scene.name == "Thumb": # If in main menu, use different offset
		gradient_y_offset = gradient_offset
		generic_y_offset = tilemap_offset
		generic_y_offset = light_offset
	
	if GlobalScript.background_movement:
		# Gradient
		gradient.position.x = sin(time * sin_values[0]) * -1 * sin_values[6]
		gradient.position.y = (sin(time * sin_values[1]) * -1 * sin_values[7]) + gradient_y_offset
		
		# Tilemaps
		buildings.position.x = sin(time * sin_values[2]) * sin_values[8]
		buildings.position.y = (sin(time * sin_values[3]) * sin_values[9]) + generic_y_offset
		buildings.modulate.a = 0.5
		
		lamp_posts.position.x = sin(time * sin_values[4]) * sin_values[10]
		lamp_posts.position.y = (sin(time * sin_values[5]) * sin_values[11]) + generic_y_offset
		lamp_posts.modulate.a = 0.75
	else:
		# Gradient
		gradient.position.x = 0
		gradient.position.y = gradient_y_offset
		
		# Tilemaps
		buildings.position.x = 0
		buildings.position.y = generic_y_offset
		buildings.modulate.a = 0.5
		
		lamp_posts.position.x = 0
		lamp_posts.position.y = generic_y_offset
		lamp_posts.modulate.a = 0.75
	
	# Lights
	for i in range(lights.size()):
		if i < light_pos.size():
			if GlobalScript.background_movement:
				lights[i].position.x = (sin(time * sin_values[4]) * sin_values[10]) + light_pos[i].x
				lights[i].position.y = (sin(time * sin_values[5]) * sin_values[11]) + generic_y_offset + light_pos[i].y
				lights[i].modulate.a = 0.75
			else:
				lights[i].position.x = light_pos[i].x
				lights[i].position.y = generic_y_offset + light_pos[i].y
				lights[i].modulate.a = 0.75
