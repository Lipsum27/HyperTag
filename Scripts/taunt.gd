extends Node2D

@export var playerID = 1
var tauntSet = 1
var suffix
var flickerFix = false

const bufferTime = 0.2
const directions = ["Jump", "Right", "Down", "Left"]

@onready var sets = {
	1: $"1",
	2: $"2",
	3: $"3",
}

var inputBuffer: Array = [0, 0, 0, 0]

func _ready() -> void:
	visible = true
	for node in sets.values():
		node.visible = false
	suffix = "_" + str(globalScript.playerInputs[playerID - 1])

func _process(delta: float) -> void:
	for dir in directions:
		var chosenDir = directions.find(dir)
		inputBuffer[chosenDir] += delta
		if not Input.is_action_pressed(dir + suffix):
			inputBuffer[chosenDir] = 0
	#print(inputBuffer)
	
	var ammountPressed = 4
	for i in inputBuffer.size():
		if inputBuffer[i] == 0:
			ammountPressed -= 1
	if !ammountPressed == 0:
		if ammountPressed == 1:
			for i in inputBuffer.size():
				if inputBuffer[i] > bufferTime:
					var targetNode = get_node(str(tauntSet) + "/" + str(i+1))
					targetNode.scale += Vector2(0.03, 0.03)
		if inputBuffer[1] > 0 and inputBuffer[3] > 0:
			if sets[tauntSet].visible == true:
				if !flickerFix:
					if tauntSet > sets.size()-1:
						tauntSet = 1
						flickerFix = true
					else:
						tauntSet += 1
						flickerFix = true
			else:
				visible = true
			for i in sets.size():
				if tauntSet == i+1:
					sets[i+1].visible = true
				else:
					sets[i+1].visible = false
		if inputBuffer[1] == 0 or inputBuffer[3] == 0:
			flickerFix = false
