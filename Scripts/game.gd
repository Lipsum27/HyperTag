extends Node2D

var PowerUpCooldown:float
var PowerUpTimeRange:Array = [2,7]

const PowerUpScene = preload("res://Scenes/power_up.tscn")

func _ready() -> void:
	GlobalScript.PowerUpCurrentlyLoaded = false
	PowerUpCooldown = randi_range(PowerUpTimeRange[0], PowerUpTimeRange[1]) #(10,20)
	
	GlobalScript.p1PowerUp = [0, 0, 0, 0]
	GlobalScript.p2PowerUp = [0, 0, 0, 0]
	GlobalScript.p3PowerUp = [0, 0, 0, 0]
	GlobalScript.p4PowerUp = [0, 0, 0, 0]

func _process(_delta: float) -> void:
	if !GlobalScript.PowerUpCurrentlyLoaded and GlobalScript.PowerUpToggle:
		if PowerUpCooldown < 0:
			var NewPowerUp = PowerUpScene.instantiate()
			add_child(NewPowerUp)
			PowerUpCooldown = randi_range(PowerUpTimeRange[0], PowerUpTimeRange[1])
		PowerUpCooldown -= _delta
