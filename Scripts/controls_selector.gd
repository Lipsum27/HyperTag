extends Control

@export var ID = 1
@onready var selector = $Button
var controls = 6 # how many

func _ready():
	selector.modulate = Color.from_hsv(0.0, 0.0, 1.0, 0.196)

func _physics_process(_delta):
	selector.icon = load("res://Assets/Sprites/Menu_Controlls_" + str(globalScript.playerInputs[ID]) + ".png")
	if globalScript.playerInputs[ID] == 0:
		selector.modulate = Color.from_hsv(0.0, 0.0, 1.0, 0.196)
	else:
		selector.modulate.h = globalScript.playerHues[ID]
		selector.modulate.s = globalScript.playerSaturation
		selector.modulate.v = 1.0
		selector.modulate.a = 1.0

func _on_button_pressed() -> void:
	for i in range(globalScript.playerInputs.size()):
		if ID == i:
			break
		if 0 == globalScript.playerInputs[i]:
			return
	
	var new_input_value = globalScript.playerInputs[ID] + 1
	
	if new_input_value > controls:
		new_input_value = 0
	
	var is_assigned = false
	
	while true:
		is_assigned = false
		
		if new_input_value == 0: # Switch to 0
			for i in range(globalScript.playerInputs.size() - (ID+1)):
				if  globalScript.playerInputs[i+ID+1] > 0:
					is_assigned = true
					break
		
		else:
			for i in range(globalScript.playerInputs.size()):
				if i == ID:
					continue
				
				if globalScript.playerInputs[i] == new_input_value:
					is_assigned = true
					break
		
		if is_assigned:
			new_input_value += 1 
			if new_input_value > controls:
				new_input_value = 0
		else:
			break
	
	if ID == 0 and new_input_value == 0:
		new_input_value = 1
	
	globalScript.playerInputs[ID] = new_input_value
