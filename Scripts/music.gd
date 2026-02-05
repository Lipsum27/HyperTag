extends AudioStreamPlayer

var TargetVolume:float = 0
var LerpSpeed:float = 2
@export var GlobalMusic:bool = false

func _process(_delta: float) -> void: # main loop
	
	if get_tree().paused:
		TargetVolume = GlobalScript.volume - 15
	else:
		TargetVolume = GlobalScript.volume
	
	volume_db = lerp(volume_db, TargetVolume, _delta * LerpSpeed)
	
	if GlobalMusic:
		if stream != GlobalScript.Music_Library[GlobalScript.Song]:
			stream = GlobalScript.Music_Library[GlobalScript.Song]
			play()

func update_volume():
	if get_tree().paused:
		TargetVolume = GlobalScript.volume - 15
	else:
		TargetVolume = GlobalScript.volume
	volume_db = TargetVolume
