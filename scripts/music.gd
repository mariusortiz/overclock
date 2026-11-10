extends AudioStreamPlayer
## Background music, loaded as an autoload so it keeps playing across scenes.


func _ready() -> void:
	(stream as AudioStreamOggVorbis).loop = true
	play()
