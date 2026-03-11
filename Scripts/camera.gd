extends Node2D

var corners = [Vector2.ZERO, Vector2.ZERO] # min, max
var margains = Vector2(500, 300) # horizontal, vertical
var shake:Vector2

# Zoom constraints
var min_zoom = 0.36
var max_zoom = 1.0

@onready var camera = $Camera2D

func _process(delta: float) -> void:
	
	calculate_borders()
	
	position = ( corners[0] + corners[1] ) / 2
	
	if 1 == globalScript.playerCount: # single player camera
		camera.zoom = camera.zoom.lerp(Vector2(0.75, 0.75), 0.1)
	else:
		handle_zoom()
	
	handle_shake(delta)

func calculate_borders():
	corners[0] = globalScript.playerPos[0]
	corners[1] = globalScript.playerPos[0]
	
	for i in globalScript.playerCount:
		var pos = globalScript.playerPos[i]
		corners[0].x = min(corners[0].x, pos.x)
		corners[0].y = min(corners[0].y, pos.y)
		corners[1].x = max(corners[1].x, pos.x)
		corners[1].y = max(corners[1].y, pos.y)

func handle_zoom():
	var screen_size = get_viewport().get_visible_rect().size
	
	var player_area_x = (corners[1].x - corners[0].x) + (margains.x * 2)
	var player_area_y = (corners[1].y - corners[0].y) + (margains.y * 2)
	
	var target_zoom_val = min(screen_size.x / player_area_x, screen_size.y / player_area_y)
	
	target_zoom_val = clamp(target_zoom_val, min_zoom, max_zoom)
	
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	camera.zoom =  camera.zoom.lerp(target_zoom, 0.1)

func handle_shake(delta):
	if globalScript.shakeDuration > 0: # Shake
		globalScript.shakeDuration -= delta
		shake = Vector2(
			randf_range(-1, 1) * globalScript.shakeIntensity,
			randf_range(-1, 1) * globalScript.shakeIntensity
		)
	else:
		shake = shake.lerp(Vector2.ZERO, 0.2 *delta*100) # decay
	
	if globalScript.screenShake:
		camera.offset = shake
	else:
		camera.offset = Vector2.ZERO
