extends Node2D

var powerUpCooldown:float
var powerUpTimeRange:Array = [2,4]

const powerUpScene = preload("res://Scenes/power_up.tscn")

func _ready() -> void:
	globalScript.powerUpCurrentlyLoaded = false
	powerUpCooldown = randi_range(powerUpTimeRange[0], powerUpTimeRange[1])
	
	globalScript.p1PowerUp = [0, 0, 0, 0]
	globalScript.p2PowerUp = [0, 0, 0, 0]
	globalScript.p3PowerUp = [0, 0, 0, 0]
	globalScript.p4PowerUp = [0, 0, 0, 0]

func _process(_delta: float) -> void:
	if !globalScript.powerUpCurrentlyLoaded and globalScript.powerUpToggle:
		if powerUpCooldown < 0:
			var newPowerUp = powerUpScene.instantiate()
			add_child(newPowerUp)
			powerUpCooldown = randi_range(powerUpTimeRange[0], powerUpTimeRange[1])
		powerUpCooldown -= _delta
