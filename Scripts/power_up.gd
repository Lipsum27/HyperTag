extends Node2D

#region why am i using so many variables?????

var Map1BasePositions:Array = [
	Vector2(0, -770),
	Vector2(1376, -704),
	Vector2(-1376, -704),
	Vector2(2315, -1089.0),
	Vector2(-2315, -1089.0),
	Vector2(1696, -80),
	Vector2(-1696, -80),
]

var Map2BasePositions:Array = [
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
var Map3BasePositions:Array = [
	Vector2(0.0, -236.0),
	Vector2(-2254.0, -236.0),
	Vector2(2254.0, -236.0),
	Vector2(-2254.0, -1740.0),
	Vector2(2254.0, -1740.0),
]

var Maps:int = 3

var PowerUpNames:Array = [
	"DoubleJump",
	"Run",
	"SizeUp",
	"SizeDown"
]

const FloatSpeed:float = 6
const SpinSpeed:float = 2
const Flip = true
var TargetSize:float = 3
var UnloadTime = GlobalScript.timer + 20
var PowerUpTime = 15

# Dont touch
var PowerUpType:String
var BasePosition:Vector2
var Activated = false
var PowerUpID:int
var BaseScaleX:float

@onready var ScaleNode = $Scale
@onready var DoubleJump = $Scale/DoubleJump
@onready var Run = $Scale/Run
@onready var SizeUp = $Scale/SizeUp
@onready var SizeDown = $Scale/SizeDown
@onready var Collision = $Collision
@onready var Particle = $Particle
@onready var CollectParticle = $CollectParticle

#endregion

func _ready() -> void:
	visible = false
	
	ScaleNode.scale = Vector2(0, 0)
	BaseScaleX = ScaleNode.scale.x
	
	var MapPositions = get( "Map" + str(GlobalScript.Level) + "BasePositions" )
	BasePosition = MapPositions[randi_range(0, MapPositions.size() - 1)]
	PowerUpID = randi_range(0, PowerUpNames.size())
	PowerUpType = PowerUpNames[PowerUpID-1]
	GlobalScript.PowerUpCurrentlyLoaded = true


func _process(_delta: float) -> void:
	for i in PowerUpNames.size(): # Show correct power up
		get_node("Scale/" + PowerUpNames[i]).visible = PowerUpType == PowerUpNames[i]
	
	ScaleNode.scale.y = lerp(ScaleNode.scale.y, TargetSize, 0.1)
	
	BaseScaleX = lerp(BaseScaleX, TargetSize, 0.1)
	
	if Flip:
		ScaleNode.scale.x = BaseScaleX * sin(GlobalScript.timer * SpinSpeed)
	else:
		ScaleNode.scale.x = BaseScaleX * abs(sin(GlobalScript.timer * SpinSpeed))
	
	position.y = BasePosition.y + (sin(GlobalScript.timer * FloatSpeed) * FloatSpeed)
	position.x = BasePosition.x
	
	visible = true
	
	if UnloadTime < GlobalScript.timer:
		GlobalScript.PowerUpCurrentlyLoaded = false
		queue_free()
	
	if UnloadTime - 1 < GlobalScript.timer:
		TargetSize = 0
		Particle.emitting = false

func _on_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players") and !Activated:
		scale.x = 1
		scale.y = 1
		TargetSize = 0
		UnloadTime = GlobalScript.timer + 1.5
		Particle.emitting = false
		CollectParticle.emitting = true
		Activated = true
		var collidedPlayer = body # Check other player id
		var collidedPlayerID = collidedPlayer.player_ID
		if collidedPlayerID == 1:
			GlobalScript.p1PowerUp[PowerUpID-1] = PowerUpTime
		if collidedPlayerID == 2:
			GlobalScript.p2PowerUp[PowerUpID-1] = PowerUpTime
		if collidedPlayerID == 3:
			GlobalScript.p3PowerUp[PowerUpID-1] = PowerUpTime
		if collidedPlayerID == 4:
			GlobalScript.p4PowerUp[PowerUpID-1] = PowerUpTime
