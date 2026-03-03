extends AudioStreamPlayer

var targetVolume:float = 0
var lerpSpeed:float = 2
@export var globalMusic:bool = false

func _process(delta: float) -> void: # main loop
	
	if get_tree().paused:
		targetVolume = globalScript.volume - 15
	else:
		targetVolume = globalScript.volume
	
	volume_db = lerp(volume_db, targetVolume, delta * lerpSpeed)
	
	if globalMusic:
		if stream != globalScript.musicLibrary[globalScript.song]:
			stream = globalScript.musicLibrary[globalScript.song]
			play()

func update_volume():
	if get_tree().paused:
		targetVolume = globalScript.volume - 15
	else:
		targetVolume = globalScript.volume
	volume_db = targetVolume
