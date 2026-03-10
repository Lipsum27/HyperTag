extends Node2D

var powerUpCooldown:float
var powerUpTimeRange:Array = [2,4]

const powerUpScene = preload("res://Scenes/power_up.tscn")

@onready var fadeHud = $CameraController/Camera2D/hudFade
@export var camera:Camera2D
var playersInside = 0

func _ready() -> void:
	globalScript.powerUpCurrentlyLoaded = false
	powerUpCooldown = randi_range(powerUpTimeRange[0], powerUpTimeRange[1])
	
	globalScript.p1PowerUp = [0, 0, 0, 0]
	globalScript.p2PowerUp = [0, 0, 0, 0]
	globalScript.p3PowerUp = [0, 0, 0, 0]
	globalScript.p4PowerUp = [0, 0, 0, 0]

func _process(delta: float) -> void:
	globalScript.fadeHud = playersInside > 0
	
	fadeHud.global_position = camera.get_screen_center_position()
	fadeHud.scale = Vector2.ONE / camera.zoom
	
	if !globalScript.powerUpCurrentlyLoaded and globalScript.powerUpToggle:
		if powerUpCooldown < 0:
			var newPowerUp = powerUpScene.instantiate()
			add_child(newPowerUp)
			powerUpCooldown = randi_range(powerUpTimeRange[0], powerUpTimeRange[1])
		powerUpCooldown -= delta

func _on_hud_hider_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		playersInside += 1

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"):
		playersInside -= 1
