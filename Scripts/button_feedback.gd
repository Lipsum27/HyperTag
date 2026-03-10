extends Button

@export var defaultSize:float = 1
@export var useOnce = false
@export var cooldown:float = 0
var remainingCooldown:float = 0
const modifier:float = 1.125
const lerpMod:float = 0.1
var goalSize:float
var fontSize:float

func _ready() -> void:
	disabled = false
	scale = Vector2(defaultSize, defaultSize)
	goalSize = defaultSize
	fontSize = defaultSize

func _process(delta: float) -> void:
	if !useOnce:
		if remainingCooldown > 0:
			disabled = true
		else:
			disabled = false
	remainingCooldown -= delta
	scale = Vector2(fontSize, fontSize)
	fontSize = lerp(fontSize, goalSize, lerpMod*100*delta)
	pivot_offset = size/2

func _on_mouse_entered() -> void:
	goalSize = defaultSize*modifier

func _on_mouse_exited() -> void:
	goalSize = defaultSize

func _on_pressed() -> void:
	if useOnce:
		disabled = true
	else:
		remainingCooldown = cooldown
	fontSize = defaultSize
