extends Control

var volume: float = 0.0

func _ready(): # setup
	GlobalScript.settingsVisible = true
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Sound/VolumeSlider").value = db_to_linear(GlobalScript.volume) * 100

func _process(_delta: float) -> void: # main loop
	if Input.is_action_just_pressed("Pause"):
		GlobalScript.SettingsShown = false
		queue_free()
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/SlimeToggle").text = "Slime Mode:\n" + str(GlobalScript.slime)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/RainToggle").text = "Rain: " + str(GlobalScript.rain)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/ScreenShakeToggle").text = "Screen Shake:\n" + str(GlobalScript.screenShake)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Gameplay/SeekerSpeedUp").text = "Seeker Speed Up:\n" + str(GlobalScript.seekerSpeedUp)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Gameplay/PowerUp").text = "Power Ups: " + str(GlobalScript.powerUpToggle)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/BackgroundMovement").text = "Animated\nBackground: " + str(GlobalScript.backgroundMovement)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/DebugHUD").text = "Show Fps: " + str(GlobalScript.debugHUD)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/SceneTransition").text = "Show Scene\nTransition: " + str(GlobalScript.doSceneTransition)
	if OS.has_feature("web"):
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").add_theme_color_override("font_color", Color("5e7ca87f"))
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").text = "Cap Fps: Unavailable\non web (Vsync)"
	else:
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").add_theme_color_override("font_color", Color("5e7ca8"))
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").text = "Cap Fps: " + str(GlobalScript.fpsCap)
	
	if get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab == 0:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Sound").add_theme_color_override("font_color", Color("ffffffff"))
	else:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Sound").add_theme_color_override("font_color", Color("5e7ca8"))
	
	if get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab == 1:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Video").add_theme_color_override("font_color", Color("ffffffff"))
	else:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Video").add_theme_color_override("font_color", Color("5e7ca8"))
	
	if get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab == 2:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Gameplay").add_theme_color_override("font_color", Color("ffffffff"))
	else:
		get_node("PanelContainer/VBoxContainer/Contents/Sidebar/Gameplay").add_theme_color_override("font_color", Color("5e7ca8"))

func _on_volume_slider_value_changed(value: float) -> void:
	if get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Sound/VolumeSlider").value == 0:
		GlobalScript.volume = -80
	else:
		GlobalScript.volume = int(linear_to_db(value) - 40)

func _on_close_pressed() -> void:
	GlobalScript.screenWipe = true
	await GlobalScript.sceneTransitionCompleted
	GlobalScript.settingsVisible = false
	queue_free()

func _on_rain_toggle_pressed() -> void:
	GlobalScript.rain = !GlobalScript.rain

func _on_slime_toggle_pressed() -> void:
	GlobalScript.slime = !GlobalScript.slime

func _on_screen_shake_toggle_pressed() -> void:
	GlobalScript.screenShake = !GlobalScript.screenShake

func _on_seeker_speed_up_pressed() -> void:
	GlobalScript.seekerSpeedUp = !GlobalScript.seekerSpeedUp

func _on_button_pressed() -> void:
	GlobalScript.powerUpToggle = !GlobalScript.powerUpToggle

func _on_background_movement_pressed() -> void:
	GlobalScript.backgroundMovement = !GlobalScript.backgroundMovement

func _on_debug_hud_pressed() -> void:
	GlobalScript.debugHUD = !GlobalScript.debugHUD

func _on_sound_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab = 0

func _on_video_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab = 1

func _on_gameplay_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab = 2


func _on_scene_transition_pressed() -> void:
	GlobalScript.doSceneTransition = !GlobalScript.doSceneTransition

func _on_fps_cap_pressed() -> void:
	if !OS.has_feature("web"):
		var currentCap = GlobalScript.fpsCapValues.find(GlobalScript.fpsCap)
		if currentCap+1 == GlobalScript.fpsCapValues.size():
			GlobalScript.fpsCap = GlobalScript.fpsCapValues[0]
		else:
			GlobalScript.fpsCap = GlobalScript.fpsCapValues[currentCap+1]
