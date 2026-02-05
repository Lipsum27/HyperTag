extends Node2D

@onready var camera_2d: Camera2D = $Camera2D
@export var zoom = 1.5#: float = .8
@export var min_zoom: float = .8#0.355
@export var max_zoom: float = 2.8
@export var lerp_speed: float = 0.08
@export var margin = Vector2(400, 200)
@export var zoom_speed = .08
@export var single_player_zoom = 1.5
@onready var screen_size = get_viewport_rect().size

# Map edges
@export var world_limit_left: float = -2684.0 
@export var world_limit_right: float = 2684.0
@export var world_limit_top: float = -2172.0
@export var world_limit_bottom: float = 184.0

var shake: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var max_x
var max_y
var min_x
var min_y

func _ready(): # setup
	camera_2d.zoom = Vector2(zoom, zoom) # default zoom
	camera_2d.limit_smoothed = false # disable default camera limits
	if GlobalScript.player_count == 1:
		max_zoom = single_player_zoom
		min_zoom = single_player_zoom

func _process(delta: float) -> void: # main loop
	# Start with the bounding box around the first player's position
	var player_positions = GlobalScript.player_pos
	var player_count = GlobalScript.player_count
	var r = Rect2(player_positions[0], Vector2.ONE) # Starts 'r' at player 1's position
	
	# Expand the rectangle to include all player positions
	for i in range(1, player_count): # Start from the second player (index 1)
		r = r.expand(player_positions[i])
		
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = 1.0 / clampf(r.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		z = 1.0 / clampf(r.size.y / screen_size.y, min_zoom, max_zoom)
	
	zoom = lerp(zoom, z, zoom_speed) 
	
	# --- 2. Center Position Calculation ---
	var new_target_position: Vector2 = Vector2.ZERO
	
	if player_count > 0:
		max_x = player_positions[0].x
		min_x = player_positions[0].x
		max_y = player_positions[0].y
		min_y = player_positions[0].y
	for i in range(GlobalScript.player_count):
		# Check Max X
		if GlobalScript.player_pos[i].x > max_x:
			max_x = GlobalScript.player_pos[i].x
		
		# Check Min X
		if GlobalScript.player_pos[i].x < min_x:
			min_x = GlobalScript.player_pos[i].x
			
		# Check Max Y
		if GlobalScript.player_pos[i].y > max_y:
			max_y = GlobalScript.player_pos[i].y
			
		# Check Min Y
		if GlobalScript.player_pos[i].y < min_y:
			min_y = GlobalScript.player_pos[i].y
		new_target_position = Vector2((max_x + min_x) / 2.0, (max_y + min_y) / 2.0)
	
	# Smoothly move the camera's target to the new center
	target_position = target_position.lerp(new_target_position, lerp_speed)
	
	var viewport_size = get_viewport_rect().size / zoom # find window size
	var half_width = viewport_size.x / 2.0
	var half_height = viewport_size.y / 2.0
	
	var clamped_x = clampf( # clamp x
		target_position.x, 
		world_limit_left + half_width, 
		world_limit_right - half_width
	)
	var clamped_y = clampf( # clamp y
		target_position.y, 
		world_limit_top + half_height, 
		world_limit_bottom - half_height
	)
	
	var final_clamped_pos = Vector2(clamped_x, clamped_y)
	
	if GlobalScript.shake_duration > 0: # Shake
		GlobalScript.shake_duration -= delta
		shake = Vector2(
			randf_range(-1, 1) * GlobalScript.shake_intensity,
			randf_range(-1, 1) * GlobalScript.shake_intensity
		)
	else:
		shake = shake.lerp(Vector2.ZERO, 0.2) # decay
	
	if GlobalScript.screen_shake:
		position = final_clamped_pos + shake # final pos w/ shake
	else:
		position = final_clamped_pos # final pos
	
	camera_2d.zoom = Vector2(zoom, zoom) # zoom
