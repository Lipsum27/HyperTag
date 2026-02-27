extends Node2D

@onready var levels = {
	1: $"1",
	2: $"2",
	3: $"3",
	4: $"4"
}

var prevLevel:int

func set_level(level: int) -> void:
	for i in levels.size():
		var currentLevel = levels[i+1]
		if currentLevel.get_parent() == self:
			remove_child(currentLevel)
	
	if levels.has(level):
		var levelNode = levels[level]
		if levelNode.get_parent() != self:
			add_child(levelNode)
		levelNode.show()

func _ready():
	prevLevel = GlobalScript.level
	set_level(GlobalScript.level)

func _process(_delta: float) -> void:
	if prevLevel != GlobalScript.level:
		prevLevel = GlobalScript.level
		set_level(GlobalScript.level)
