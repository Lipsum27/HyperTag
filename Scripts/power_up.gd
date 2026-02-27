extends Node2D

# other power up shit is in game.gd

#region why am i using so many variables?????

var map1basePositions:Array = [
	Vector2(0, -770),
	Vector2(1376, -704),
	Vector2(-1376, -704),
	Vector2(2315, -1089.0),
	Vector2(-2315, -1089.0),
	Vector2(1696, -80),
	Vector2(-1696, -80),
]

var map2basePositions:Array = [
	Vector2(-2314.0, -1276.0),
	Vector2(-1751.0, -758.0),
	Vector2(-1100.0, -1262.0),
	Vector2(-1093.0, -1266.0),
	Vector2(-915.0, -915.0),
	Vector2(675.0, -505.0),
	Vector2(681.0, -1150.0),
	Vector2(1118.0, -1797.0),
	Vector2(1521.0, -899.0),
	Vector2(1853.0, -511.0),
	Vector2(2310.0, -1405.0),
]
var map3basePositions:Array = [
	Vector2(0.0, -236.0),
	Vector2(-2254.0, -236.0),
	Vector2(2254.0, -236.0),
	Vector2(-2254.0, -1740.0),
	Vector2(2254.0, -1740.0),
]

var map4basePositions:Array = [
	Vector2(-547,-606),
	Vector2(547,-606),
	Vector2(-547,-1818),
	Vector2(547,-1818),
	Vector2(-1920.0,-515.0),
	Vector2(1920.0,-515.0),
	Vector2(1920.0,-1476.0),
	Vector2(-1920.0,-1476.0),
]

var maps:int = 4

var powerUpNames:Array = [
	"DoubleJump",
	"Run",
	"SizeUp",
	"SizeDown"
]

const floatSpeed:float = 6
const spinSpeed:float = 2
const flip = true
var targetSize:float = 3
var unloadTime = GlobalScript.timer + 20
var powerUpTime = 15

# Dont touch
var powerUpType:String
var basePosition:Vector2
var activated = false
var powerUpID:int
var baseScaleX:float

@onready var scaleNode = $Scale
@onready var doubleJump = $Scale/DoubleJump
@onready var run = $Scale/Run
@onready var sizeUp = $Scale/SizeUp
@onready var sizeDown = $Scale/SizeDown
@onready var collision = $Collision
@onready var particle = $Particle
@onready var collectParticle = $CollectParticle

#endregion

func _ready() -> void:
	visible = false
	
	scaleNode.scale = Vector2(0, 0)
	baseScaleX = scaleNode.scale.x
	
	var mapPositions = get( "map" + str(GlobalScript.level) + "basePositions" )
	basePosition = mapPositions[randi_range(0, mapPositions.size() - 1)]
	powerUpID = randi_range(0, powerUpNames.size())
	powerUpType = powerUpNames[powerUpID-1]
	GlobalScript.powerUpCurrentlyLoaded = true


func _process(delta: float) -> void:
	for i in powerUpNames.size(): # Show correct power up
		get_node("Scale/" + powerUpNames[i]).visible = powerUpType == powerUpNames[i]
	
	scaleNode.scale.y = lerp(scaleNode.scale.y, targetSize, 0.1*delta*100)
	
	baseScaleX = lerp(baseScaleX, targetSize, 0.1*delta*100)
	
	if flip:
		scaleNode.scale.x = baseScaleX * sin(GlobalScript.timer * spinSpeed)
	else:
		scaleNode.scale.x = baseScaleX * abs(sin(GlobalScript.timer * spinSpeed))
	
	position.y = basePosition.y + (sin(GlobalScript.timer * floatSpeed) * floatSpeed)
	position.x = basePosition.x
	
	visible = true
	
	if unloadTime < GlobalScript.timer:
		GlobalScript.powerUpCurrentlyLoaded = false
		queue_free()
	
	if unloadTime - 1 < GlobalScript.timer:
		targetSize = 0
		particle.emitting = false

func _on_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players") and !activated:
		scale.x = 1
		scale.y = 1
		targetSize = 0
		unloadTime = GlobalScript.timer + 1.5
		particle.emitting = false
		collectParticle.emitting = true
		activated = true
		var collidedPlayer = body # Check other player id
		var collidedPlayerID = collidedPlayer.player_ID
		if collidedPlayerID == 1:
			GlobalScript.p1PowerUp[powerUpID-1] = powerUpTime
		if collidedPlayerID == 2:
			GlobalScript.p2PowerUp[powerUpID-1] = powerUpTime
		if collidedPlayerID == 3:
			GlobalScript.p3PowerUp[powerUpID-1] = powerUpTime
		if collidedPlayerID == 4:
			GlobalScript.p4PowerUp[powerUpID-1] = powerUpTime
