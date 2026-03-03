extends Node2D

@onready var camera2d: Camera2D = $Camera2D
@export var zoom = 1.5#: float = .8
@export var minZoom: float = .8#0.355
@export var maxZoom: float = 2.8
@export var lerpSpeed: float = 0.08
@export var margin = Vector2(400, 200)
@export var zoomSpeed = .08
@export var singlePlayerZoom = 1.5
@onready var screenSize = get_viewport_rect().size

# Map edges
var worldLimits = [-2684.0, 2684.0, -2172.0, 184.0] # Left, right, top, bottom

var shake: Vector2 = Vector2.ZERO
var targetPosition: Vector2 = Vector2.ZERO
var maxX
var maxY
var minX
var minY

func _ready(): # setup
	camera2d.zoom = Vector2(zoom, zoom) # default zoom
	camera2d.limit_smoothed = false # disable default camera limits
	if globalScript.playerCount == 1:
		maxZoom = singlePlayerZoom
		minZoom = singlePlayerZoom

func _process(delta: float) -> void: # main loop
	# Start with the bounding box around the first player's position
	var playerPositions = globalScript.playerPos
	var playerCount = globalScript.playerCount
	var r = Rect2(playerPositions[0], Vector2.ONE) # Starts 'r' at player 1's position
	
	# Expand the rectangle to include all player positions
	for i in range(1, playerCount): # Start from the second player (index 1)
		r = r.expand(playerPositions[i])
		
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	
	var z
	if r.size.x > r.size.y * screenSize.aspect():
		z = 1.0 / clampf(r.size.x / screenSize.x, minZoom, maxZoom)
	else:
		z = 1.0 / clampf(r.size.y / screenSize.y, minZoom, maxZoom)
	
	zoom = lerp(zoom, z, zoomSpeed *delta*100) 
	
	# --- 2. Center Position Calculation ---
	var new_targetPosition: Vector2 = Vector2.ZERO
	
	if playerCount > 0:
		maxX = playerPositions[0].x
		minX = playerPositions[0].x
		maxY = playerPositions[0].y
		minY = playerPositions[0].y
	for i in range(globalScript.playerCount):
		# Check Max X
		if globalScript.playerPos[i].x > maxX:
			maxX = globalScript.playerPos[i].x
		
		# Check Min X
		if globalScript.playerPos[i].x < minX:
			minX = globalScript.playerPos[i].x
			
		# Check Max Y
		if globalScript.playerPos[i].y > maxY:
			maxY = globalScript.playerPos[i].y
			
		# Check Min Y
		if globalScript.playerPos[i].y < minY:
			minY = globalScript.playerPos[i].y
		new_targetPosition = Vector2((maxX + minX) / 2.0, (maxY + minY) / 2.0)
	
	# Smoothly move the camera's target to the new center
	targetPosition = targetPosition.lerp(new_targetPosition, lerpSpeed *delta*100)
	
	var viewport_size = get_viewport_rect().size / zoom # find window size
	var half_width = viewport_size.x / 2.0
	var half_height = viewport_size.y / 2.0
	
	var clamped_x = clampf( # clamp x
		targetPosition.x, 
		worldLimits[0] + half_width, 
		worldLimits[1] - half_width
	)
	var clamped_y = clampf( # clamp y
		targetPosition.y, 
		worldLimits[2] + half_height, 
		worldLimits[3] - half_height
	)
	
	var final_clamped_pos = Vector2(clamped_x, clamped_y)
	
	if globalScript.shakeDuration > 0: # Shake
		globalScript.shakeDuration -= delta
		shake = Vector2(
			randf_range(-1, 1) * globalScript.shakeIntensity,
			randf_range(-1, 1) * globalScript.shakeIntensity
		)
	else:
		shake = shake.lerp(Vector2.ZERO, 0.2 *delta*100) # decay
	
	if globalScript.screenShake:
		camera2d.offset = shake
	else:
		camera2d.offset = Vector2.ZERO
	position = final_clamped_pos # final pos
	
	camera2d.zoom = Vector2(zoom, zoom) # zoom
