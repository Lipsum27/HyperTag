extends Button

@export var DefaultSize:float = 1
const Modifier:float = 1.125
const LerpMod:float = 0.1
var GoalSize:float
var FontSize:float

func _ready() -> void:
	#add_theme_font_size_override("font_size", int(DefaultSize))
	scale = Vector2(DefaultSize, DefaultSize)
	GoalSize = DefaultSize
	FontSize = DefaultSize

func _process(_delta: float) -> void:
	scale = Vector2(FontSize, FontSize)
	FontSize = lerp(FontSize, GoalSize, LerpMod)
	pivot_offset = size/2

func _on_mouse_entered() -> void:
	GoalSize = DefaultSize*Modifier

func _on_mouse_exited() -> void:
	GoalSize = DefaultSize

func _on_pressed() -> void:
	FontSize = DefaultSize
