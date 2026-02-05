extends Control

@export var ID = 1
@onready var selector = $Button

func _ready():
	selector.modulate = Color.from_hsv(0.0, 0.0, 1.0, 0.196)

func _physics_process(_delta):
	selector.icon = load("res://Assets/Sprites/Menu_Controlls_" + str(GlobalScript.player_inputs[ID]) + ".png")
	if GlobalScript.player_inputs[ID] == 0:
		selector.modulate = Color.from_hsv(0.0, 0.0, 1.0, 0.196)
	else:
		if ID == 0:
			selector.modulate = Color.from_hsv(0.0, 0.5, 1.0, 1.0)
		elif ID == 1:
			selector.modulate = Color.from_hsv(0.169, 0.5, 1.0, 1.0)
		elif ID == 2:
			selector.modulate = Color.from_hsv(0.326, 0.5, 1.0, 1.0)
		elif ID == 3:
			selector.modulate = Color.from_hsv(0.589, 0.5, 1.0, 1.0)

func _on_button_pressed() -> void:
	for i in range(GlobalScript.player_inputs.size()): # Loop through player_inputs
		if ID == i: # Reach player
			break # Continue as usual
		if 0 == GlobalScript.player_inputs[i]: # Reach empty slot
			return # Stop script
	
	var new_input_value = GlobalScript.player_inputs[ID] + 1
	
	if new_input_value > 5:
		new_input_value = 0
	
	var is_assigned = false
	
	while true:
		is_assigned = false # if false, new value fine, will be set to true if issue found
		
		if new_input_value == 0: # Switch to 0
			for i in range(GlobalScript.player_inputs.size() - (ID+1)): # 1 offset to avoid checking own value
				if  GlobalScript.player_inputs[i+ID+1] > 0:
					is_assigned = true
					break # leave loop
		
		else: # Switch to anything else
			for i in range(GlobalScript.player_inputs.size()): # loop through inputs
				if i == ID: # don't check own value
					continue
				
				if GlobalScript.player_inputs[i] == new_input_value: # conflict found
					is_assigned = true
					break # conflict found
		
		if is_assigned: # Conflict found, repeat with next value
			new_input_value += 1 
			if new_input_value > 5:
				new_input_value = 0
		else: # No issue
			break
	
	if ID == 0 and new_input_value == 0:
		new_input_value = 1
	
	GlobalScript.player_inputs[ID] = new_input_value
