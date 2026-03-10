extends Control

var volume: float = 0.0

func _ready(): # setup
	globalScript.settingsVisible = true
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Sound/VolumeSlider").value = db_to_linear(globalScript.volume) * 100

func _process(_delta: float) -> void: # main loop
	if Input.is_action_just_pressed("Pause"):
		globalScript.settingsVisible = false
		queue_free()
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/SlimeToggle").text = "Slime Mode:\n" + str(globalScript.slime)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/RainToggle").text = "Rain: " + str(globalScript.rain)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/ScreenShakeToggle").text = "Screen Shake:\n" + str(globalScript.screenShake)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Gameplay/SeekerSpeedUp").text = "Seeker Speed Up:\n" + str(globalScript.seekerSpeedUp)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Gameplay/PowerUp").text = "Power Ups: " + str(globalScript.powerUpToggle)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/BackgroundMovement").text = "Animated\nBackground: " + str(globalScript.backgroundMovement)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/DebugHUD").text = "Show Fps: " + str(globalScript.debugHUD)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/SceneTransition").text = "Show Scene\nTransition: " + str(globalScript.doSceneTransition)
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Gameplay/Taunts").text = "Taunts: " + str(globalScript.tauntsEnabled)
	if OS.has_feature("web"):
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").add_theme_color_override("font_color", Color("5e7ca87f"))
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").text = "Cap Fps: Unavailable\non web (Vsync)"
	else:
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").add_theme_color_override("font_color", Color("5e7ca8"))
		get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options/Video/FpsCap").text = "Cap Fps: " + str(globalScript.fpsCap)
	
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
		globalScript.volume = -80
	else:
		globalScript.volume = int(linear_to_db(value) - 40)

func _on_close_pressed() -> void:
	globalScript.screenWipe = true
	await globalScript.sceneTransitionCompleted
	globalScript.settingsVisible = false
	#get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	queue_free()

func _on_rain_toggle_pressed() -> void:
	globalScript.rain = !globalScript.rain

func _on_slime_toggle_pressed() -> void:
	globalScript.slime = !globalScript.slime

func _on_screen_shake_toggle_pressed() -> void:
	globalScript.screenShake = !globalScript.screenShake

func _on_seeker_speed_up_pressed() -> void:
	globalScript.seekerSpeedUp = !globalScript.seekerSpeedUp

func _on_button_pressed() -> void:
	globalScript.powerUpToggle = !globalScript.powerUpToggle

func _on_background_movement_pressed() -> void:
	globalScript.backgroundMovement = !globalScript.backgroundMovement

func _on_debug_hud_pressed() -> void:
	globalScript.debugHUD = !globalScript.debugHUD

func _on_sound_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab = 0

func _on_video_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab = 1

func _on_gameplay_pressed() -> void:
	get_node("PanelContainer/VBoxContainer/Contents/OptionsScroll/Options").current_tab = 2


func _on_scene_transition_pressed() -> void:
	globalScript.doSceneTransition = !globalScript.doSceneTransition

func _on_fps_cap_pressed() -> void:
	if !OS.has_feature("web"):
		var currentCap = globalScript.fpsCapValues.find(globalScript.fpsCap)
		if currentCap+1 == globalScript.fpsCapValues.size():
			globalScript.fpsCap = globalScript.fpsCapValues[0]
		else:
			globalScript.fpsCap = globalScript.fpsCapValues[currentCap+1]

func _on_taunts_pressed() -> void:
	globalScript.tauntsEnabled = !globalScript.tauntsEnabled
