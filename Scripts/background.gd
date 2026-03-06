extends Node2D

@onready var background = $Tilemaps/Background
@onready var buildings = $Tilemaps/Buildings
@onready var lampPosts = $Tilemaps/LampPost

# Variables
const backgroundOffset = 500
const tilemapOffset = 850
const lightOffset = 850
var time = 0
var lightPos: Array[Vector2] = [
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
		sin_values.append(randf_range(-5, 5))

func _process(delta: float) -> void:
	get_node("Rain").visible = globalScript.rain # rain toggle
	get_node("RainForeground").visible = globalScript.rain # rain toggle
	time += randf_range(0.5, 2)*delta*100
	move()

func move(): # Set offsets
	var background_y_offset = -350
	var generic_y_offset = -500
	
	if get_tree().current_scene.name == "MainMenu" or get_tree().current_scene.name == "Countdown" or get_tree().current_scene.name == "background" or get_tree().current_scene.name == "Thumb": # If in main menu, use different offset
		background_y_offset = backgroundOffset
		generic_y_offset = tilemapOffset
		generic_y_offset = lightOffset
	
	if globalScript.backgroundMovement:
		# background
		background.position.x = sin(time * sin_values[0]) * -1 * sin_values[6]
		background.position.y = (sin(time * sin_values[1]) * -1 * sin_values[7]) + background_y_offset
		
		# Tilemaps
		buildings.position.x = sin(time * sin_values[2]) * sin_values[8]
		buildings.position.y = (sin(time * sin_values[3]) * sin_values[9]) + generic_y_offset
		buildings.modulate.a = 0.5
		
		lampPosts.position.x = sin(time * sin_values[4]) * sin_values[10]
		lampPosts.position.y = (sin(time * sin_values[5]) * sin_values[11]) + generic_y_offset
		lampPosts.modulate.a = 0.75
	else:
		# background
		background.position.x = 0
		background.position.y = background_y_offset
		
		# Tilemaps
		buildings.position.x = 0
		buildings.position.y = generic_y_offset
		buildings.modulate.a = 0.5
		
		lampPosts.position.x = 0
		lampPosts.position.y = generic_y_offset
		lampPosts.modulate.a = 0.75
	
	# Lights
	for i in range(lightPos.size()):
		var currentNode = get_node("Tilemaps/LampPost/Lights/" + str(i+1))
		if globalScript.backgroundMovement:
			currentNode.position.x = (sin(time * sin_values[4]) * sin_values[10]) + lightPos[i].x
			currentNode.position.y = (sin(time * sin_values[5]) * sin_values[11]) + generic_y_offset + lightPos[i].y
			currentNode.modulate.a = 0.75
		else:
			currentNode.position.x = lightPos[i].x
			currentNode.position.y = generic_y_offset + lightPos[i].y
			currentNode.modulate.a = 0.75
