extends Node2D

@onready var levels = {
	1: $"1",
	2: $"2",
	3: $"3"
}

var PrevLevel:int

func set_level(level: int) -> void:
	# Hide all levels first
	for i in levels.size():
		var current_level = levels[i+1]
		#if current_level: #.is_visible() and current_level.get_parent() == self:
		if current_level.get_parent() == self:
			remove_child(current_level)
	
	# Show the requested level
	if levels.has(level):
		var level_node = levels[level]
		if level_node.get_parent() != self:
			add_child(level_node)
		level_node.show()

func _ready():
	PrevLevel = GlobalScript.Level
	set_level(GlobalScript.Level)

func _process(_delta: float) -> void:
	if PrevLevel != GlobalScript.Level:
		PrevLevel = GlobalScript.Level
		set_level(GlobalScript.Level)
