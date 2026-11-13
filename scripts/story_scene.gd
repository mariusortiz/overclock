class_name StoryScene
extends AnimeDirector
## A chapter's scene in the story mode: an anime scene (see AnimeDirector)
## played live before the mission, shorter than the episode it retells.
## Instead of quitting at the end, it says it is done.

signal done


func _ready() -> void:
	super()
	Music.play_track(Music.Track.STORY)
	# A first shot for the title card, before the set is built.
	_dolly(Vector3(0, 2, 10), Vector3(0, 2, 10), Vector3.ZERO, Vector3.ZERO, 1.0)


func _run() -> void:
	await _story()
	await _until(duration)
	done.emit()
