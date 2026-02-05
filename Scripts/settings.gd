extends Control

var volume: float = 0.0

func _ready(): # setup
	GlobalScript.SettingsShown = true
	get_node("PanelContainer/VBoxContainer/Contents/Options/Sound/VolumeSlider").value = db_to_linear(GlobalScript.volume) * 100

func _process(_delta: float) -> void: # main loop
	if Input.is_action_just_pressed("Pause"):
		GlobalScript.SettingsShown = false
		queue_free()
	get_node("PanelContainer/VBoxContainer/Contents/Options/Video/SlimeToggle").text = "Slime Mode:\n" + str(GlobalScript.slime)
	get_node("PanelContainer/VBoxContainer/Contents/Options/Video/RainToggle").text = "Rain: " + str(GlobalScript.rain)
	get_node("PanelContainer/VBoxContainer/Contents/Options/Video/ScreenShakeToggle").text = "Screen Shake:\n" + str(GlobalScript.screen_shake)
	get_node("PanelContainer/VBoxContainer/Contents/Options/Gameplay/SeekerSpeedUp").text = "Seeker Speed Up:\n" + str(GlobalScript.seeker_speed_up)
	get_node("PanelContainer/VBoxContainer/Contents/Options/Gameplay/PowerUp").text = "Power Ups: " + str(GlobalScript.PowerUpToggle)
	get_node("PanelContainer/VBoxContainer/Contents/Options/Video/BackgroundMovement").text = "Animated\nBackground: " + str(GlobalScript.background_movement)
	get_node("PanelContainer/VBoxContainer/Contents/Options/Video/DebugHUD").text = "Debug HUD: " + str(GlobalScript.DebugHUD)
	
	if get_node("PanelContainer/VBoxContainer/Contents/Options").current_tab == 0:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Sound").add_theme_color_override("font_color", Color("ffffffff"))
	else:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Sound").add_theme_color_override("font_color", Color("5e7ca8"))
	
	if get_node("PanelContainer/VBoxContainer/Contents/Options").current_tab == 1:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Video").add_theme_color_override("font_color", Color("ffffffff"))
	else:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Video").add_theme_color_override("font_color", Color("5e7ca8"))
	
	if get_node("PanelContainer/VBoxContainer/Contents/Options").current_tab == 2:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Gameplay").add_theme_color_override("font_color", Color("ffffffff"))
	else:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Gameplay").add_theme_color_override("font_color", Color("5e7ca8"))

func _on_volume_slider_value_changed(value: float) -> void:
	if get_node("PanelContainer/VBoxContainer/Contents/Options/Sound/VolumeSlider").value == 0:
		GlobalScript.volume = -80
	else:
		GlobalScript.volume = int(linear_to_db(value) - 40)

func _on_close_pressed() -> void:
	GlobalScript.ScreenWipe = true
	await GlobalScript.scene_transition_completed
	GlobalScript.SettingsShown = false
	queue_free()

func _on_rain_toggle_pressed() -> void:
	GlobalScript.rain = !GlobalScript.rain

func _on_slime_toggle_pressed() -> void:
	GlobalScript.slime = !GlobalScript.slime

func _on_screen_shake_toggle_pressed() -> void:
	GlobalScript.screen_shake = !GlobalScript.screen_shake

func _on_seeker_speed_up_pressed() -> void:
	GlobalScript.seeker_speed_up = !GlobalScript.seeker_speed_up

func _on_button_pressed() -> void:
	GlobalScript.PowerUpToggle = !GlobalScript.PowerUpToggle

func _on_background_movement_pressed() -> void:
	GlobalScript.background_movement = !GlobalScript.background_movement

func _on_debug_hud_pressed() -> void:
	GlobalScript.DebugHUD = !GlobalScript.DebugHUD

func _on_sound_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/Options").current_tab = 0

func _on_video_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/Options").current_tab = 1

func _on_gameplay_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/Options").current_tab = 2
