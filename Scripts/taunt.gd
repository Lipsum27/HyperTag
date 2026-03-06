extends Node2D

@export var playerID = 1
var state = 0 # 0 = waiting, 1 = selecting, 2 = taunting
var currentSet = 0
var selectedDirection
var setBuffer = false
var swayValues = [10, 30, 0.5, 1.5]
var targetScale = 0.3
var directionSelected = false
var tauntSetup = false
var spawnedTime:float
var tauntTimeout = 4
var sets = [
	"0",
	"1",
	"2"
]
var directionInputs = [
	"Jump",
	"Right",
	"Down",
	"Left"
]
var swayDistances = [0, 0, 0, 0]

var squarePositions = [
	Vector2(0, -175),
	Vector2(175, 0),
	Vector2(0, 175),
	Vector2(-175, 0)
]

func _ready() -> void:
	for i in sets.size():
		get_node(sets[i]).visible = false
	if globalScript.playerInputs[playerID-1] == 0:
		queue_free()

func _process(_delta: float) -> void:
	position = globalScript.playerPos[playerID-1]
	if state == 0:
		for i in sets.size():
			get_node(sets[i]).visible = false
		if Input.is_action_just_pressed("Taunt_" + str(globalScript.playerInputs[playerID-1])):
			setBuffer = true
			swayDistances = []
			for i in range(8):
				swayDistances.append(randf_range(swayValues[0], swayValues[1]))
			for i in range(8):
				swayDistances.append(randf_range(swayValues[2], swayValues[3]))
			targetScale = 0
			directionSelected = false
			state = 1
	if state == 1:
		for i in 4:
			get_node(str(currentSet) + "/" + str(i)).visible = true
			get_node(str(currentSet) + "/" + str(i)).scale = Vector2(5, 5)
		var currentSetNode = get_node(str(currentSet))
		currentSetNode.scale = lerp(currentSetNode.scale, Vector2(targetScale, targetScale), 0.2)
		if currentSetNode.scale.x < 0.01 && directionSelected:
			visible = false
			tauntSetup = true
			state = 2
			spawnedTime = globalScript.timer
			currentSetNode.scale = Vector2(0.3, 0.3)
		modulate.a = 0.3
		if !directionSelected:
			targetScale = 0.3
		for i in sets.size():
			if i == currentSet:
				get_node(sets[i]).visible = true
			else:
				get_node(sets[i]).visible = false
		for i in 4:
			get_node(str(currentSet) + "/" + str(i)).position = Vector2(sin(globalScript.timer * swayDistances[i+8]) * swayDistances[i], sin(globalScript.timer * swayDistances[i+12]) * swayDistances[i+4]) + squarePositions[i]
		if !setBuffer and !directionSelected:
			if Input.is_action_just_pressed("Taunt_" + str(globalScript.playerInputs[playerID-1])):
				if currentSet == sets.size()-1:
					currentSet = 0
				else:
					currentSet += 1
				currentSetNode = get_node(str(currentSet))
				currentSetNode.scale = Vector2(0, 0)
		setBuffer = false
		for i in directionInputs.size():
			if Input.is_action_just_pressed(directionInputs[i] + "_" + str(globalScript.playerInputs[playerID-1])):
				selectedDirection = i
				directionSelected = true
				targetScale = 0
	if state == 2:
		var chosenTaunt = get_node(str(currentSet) + "/" + str(selectedDirection))
		chosenTaunt.position = squarePositions[0]
		chosenTaunt.scale = lerp(chosenTaunt.scale, Vector2(targetScale, targetScale), 0.2)
		modulate.a = 0.8
		if Input.is_action_just_pressed("Taunt_" + str(globalScript.playerInputs[playerID-1])):
			targetScale = 0
		if tauntSetup:
			targetScale = 5
			chosenTaunt.scale = Vector2(0.15, 0.15)
			for i in 4:
				if get_node(str(currentSet) + "/" + str(i)) != chosenTaunt:
					get_node(str(currentSet) + "/" + str(i)).visible = false
			tauntSetup = false
			visible = true
		if chosenTaunt.scale.x < 0.1:
			state = 0
		if globalScript.timer > spawnedTime + tauntTimeout:
			state = 0
