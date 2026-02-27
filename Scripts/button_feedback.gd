extends Button

@export var defaultSize:float = 1
const modifier:float = 1.125
const lerpMod:float = 0.1
var goalSize:float
var fontSize:float

func _ready() -> void:
	#add_theme_fontSize_override("fontSize", int(defaultSize))
	scale = Vector2(defaultSize, defaultSize)
	goalSize = defaultSize
	fontSize = defaultSize

func _process(delta: float) -> void:
	scale = Vector2(fontSize, fontSize)
	fontSize = lerp(fontSize, goalSize, lerpMod*100*delta)
	pivot_offset = size/2

func _on_mouse_entered() -> void:
	goalSize = defaultSize*modifier

func _on_mouse_exited() -> void:
	goalSize = defaultSize

func _on_pressed() -> void:
	fontSize = defaultSize
